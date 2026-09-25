//
//  Created by Anton Heestand on 2022-04-11.
//

import Foundation
import Spatial
import SpatialExtensions
import TextureMap
import PixelColor

extension Graphic3D {
    
    private struct SamplePlane3DUniforms: Uniforms {
        let axis: UInt32
        let index: UInt32
    }

    private struct Sample3DUniforms: Uniforms {
        let location: VectorUniform
    }

    enum SubVoxelError: LocalizedError {
        case voxelLocationOutOfBounds
        var errorDescription: String? {
            switch self {
            case .voxelLocationOutOfBounds:
                "Sub voxel location is out of bounds."
            }
        }
    }
    
        /// Sample at a `location` coordinate, if the coordinate is fractional nearest voxels will be interpolated.
        ///
        /// Origin is at far top left.
    public func subVoxel(at location: Point3D) async throws -> PixelColor {
        try await subVoxel(x: location.x, y: location.y, z: location.z)
    }
    
        /// Sample at an `x`, `y` and `z` coordinate, if the coordinate is fractional nearest voxels will be interpolated.
        ///
        /// Origin is at far top left.
    public func subVoxel(x: CGFloat, y: CGFloat, z: CGFloat) async throws -> PixelColor {
        try await subVoxel(u: x / (resolution.width - 1.0),
                           v: y / (resolution.height - 1.0),
                           w: z / (resolution.depth - 1.0))
    }
    
        /// Sample at relative `uvw` coordinates
        ///
        /// `u` is horizontal, `v` is vertical, `w` is depth, between `0.0` and `1.0`.
        ///
        /// Origin is at top left.
    public func subVoxel(u: CGFloat, v: CGFloat, w: CGFloat) async throws -> PixelColor {
        guard u >= 0.0, u <= 1.0, v >= 0.0, v <= 1.0, w >= 0.0, w <= 1.0 else {
            throw SubVoxelError.voxelLocationOutOfBounds
        }
        let uvw = Point3D(x: u, y: v, z: w)
        let location: Point3D = uvw * (resolution - 1.0)
        let graphic: Graphic3D = try await Renderer.render(
            name: "Sample 3D",
            shader: .name("sampleVoxel"),
            graphics: [self],
            uniforms: Sample3DUniforms(
                location: location.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: Size3D(width: 1, height: 1, depth: 1),
                colorSpace: colorSpace,
                bits: ._32
            ),
            options: EffectOptions.edgeStretch.spatialRenderOptions
        )
        return try await graphic.firstVoxelColor
    }
}

extension Graphic3D {
    
    /// Sample
    ///
    /// Fraction 0.0 is the first plane
    ///
    /// Fraction 1.0 is the last plane
    public func sample(fraction: Double, axis: Axis = .z) async throws -> Graphic {
                
        let index: Int = {
            switch axis {
            case .x:
                return Int(round(fraction * resolution.width - 1.0))
            case .y:
                return Int(round(fraction * resolution.height - 1.0))
            case .z:
                return Int(round(fraction * resolution.depth - 1.0))
            }
        }()
        
        return try await sample(index: index, axis: axis)
    }
    
    public func sample(index: Int, axis: Axis = .z) async throws -> Graphic {
        let length = axis == .x ? width : axis == .y ? height : depth
        guard index >= 0, index < Int(length) else {
            throw SubVoxelError.voxelLocationOutOfBounds
        }
        if axis != .z {
            return try await Renderer.render(
                name: "Sample Plane 3D",
                shader: .name("samplePlane3d"),
                graphics: [self],
                uniforms: SamplePlane3DUniforms(axis: axis.index, index: UInt32(index)),
                metadata: Renderer.Metadata(
                    resolution: CGSize(width: axis == .x ? depth : width,
                                       height: axis == .y ? depth : height),
                    colorSpace: colorSpace,
                    bits: bits
                )
            )
        }
        
        let texture = try await texture.sample3d(index: index, axis: axis.tmAxis, bits: bits)
        
        return Graphic(name: "Sample", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
    public struct SampleProgress: Sendable {
        public let index: Int
        public let count: Int
        public var fraction: CGFloat {
            CGFloat(index) / CGFloat(count - 1)
        }
        actor Manager: Sendable {
            private let count: Int
            private var index: Int = 0
            private let progress: @Sendable (SampleProgress) async -> ()
            init(count: Int, progress: @escaping @Sendable (SampleProgress) async -> ()) {
                self.count = count
                self.progress = progress
            }
            func increment() async {
                await progress(SampleProgress(index: index, count: count))
                index += 1
            }
        }
    }
    
    public func samples(progress: (@Sendable (SampleProgress) async -> ())? = nil) async throws -> [Graphic] {
        
        let axis: Axis = .z
        
        let count: Int = {
            switch axis {
            case .x:
                return Int(resolution.width)
            case .y:
                return Int(resolution.height)
            case .z:
                return Int(resolution.depth)
            }
        }()
        
        let progressManager: SampleProgress.Manager? = if let progress {
            SampleProgress.Manager(count: count, progress: progress)
        } else { nil }
        
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
            
            for index in 0..<count {
                group.addTask {
                    let graphic: Graphic = try await self.sample(index: index/*, axis: axis*/)
                    await progressManager?.increment()
                    return (index, graphic)
                }
            }
            
            var graphics: [(Int, Graphic)] = []
            
            for try await (index, graphic) in group {
                graphics.append((index, graphic))
            }
            
            return graphics
                .sorted(by: { leadingPack, trailingPack in
                    leadingPack.0 < trailingPack.0
                })
                .map(\.1)
        }
        
        return graphics
    }
}
