//
//  Created by Anton Heestand on 2023-04-27.
//

import CoreGraphics
import Spatial
import SpatialExtensions
import TextureMap
import PixelColor

extension Graphic3D {
    
    private struct Crop3DUniforms: Uniforms {
        let origin: VectorUniform
        let size: VectorUniform
    }
    
    public func voxel(
        u: CGFloat,
        v: CGFloat,
        w: CGFloat,
        options: EffectOptions = []
    ) async throws -> PixelColor {
        let x: Int = Int(round(CGFloat(width - 1) * u))
        let y: Int = Int(round(CGFloat(height - 1) * v))
        let z: Int = Int(round(CGFloat(depth - 1) * w))
        return try await voxel(x: x, y: y, z: z, options: options)
    }
    
    public func voxel(
        x: Int,
        y: Int,
        z: Int,
        options: EffectOptions = []
    ) async throws -> PixelColor {
        let x: Int = min(max(x, 0), Int(width) - 1)
        let y: Int = min(max(y, 0), Int(height) - 1)
        let z: Int = min(max(z, 0), Int(depth) - 1)
        let origin = Point3D(x: Double(x), y: Double(y), z: Double(z))
        let size = Size3D(width: 1, height: 1, depth: 1)
        let frame = Rect3D(origin: origin, size: size)
        let graphic: Graphic3D = try await crop(to: frame, options: options)
        return try await graphic.voxelColors[0][0][0]
    }
    
    public func crop(
        to frame: Rect3D,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let resolution: Size3D = frame.size
        
        let relativeOrigin = Point3D(x: frame.origin.x / self.resolution.width,
                                     y: frame.origin.y / self.resolution.height,
                                     z: frame.origin.z / self.resolution.depth)
        let relativeSize = Size3D(width: frame.size.width / self.resolution.width,
                                  height: frame.size.height / self.resolution.height,
                                  depth: frame.size.depth / self.resolution.depth)
        
        return try await Renderer.render(
            name: "Crop 3D",
            shader: .name("crop3d"),
            graphics: [self],
            uniforms: Crop3DUniforms(
                origin: relativeOrigin.uniform,
                size: relativeSize.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: options.spatialRenderOptions
        )
    }
}
