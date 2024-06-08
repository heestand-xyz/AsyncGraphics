//
//  Created by Anton Heestand on 2022-04-24.
//

import Foundation
import Spatial
import SpatialExtensions
import PixelColor

extension Graphic3D {
    
    private struct Stack3DUniforms {
        let backgroundColor: ColorUniform
        let leadingCenter: VectorUniform
        let leadingSize: VectorUniform
        let trailingCenter: VectorUniform
        let trailingSize: VectorUniform
    }
    
    private enum StackAxis: Int {
        case horizontal = 0
        case vertical = 1
        case depth = 2
    }
    
    public struct Alignment3D: Codable, Hashable {
        
        @EnumMacro
        public enum X: String, GraphicEnum {
            case leading
            case center
            case trailing
            public var vector: Int {
                switch self {
                case .leading: -1
                case .center: 0
                case .trailing: 1
                }
            }
        }
        public var x: X
        
        @EnumMacro
        public enum Y: String, GraphicEnum {
            case top
            case center
            case bottom
            public var vector: Int {
                switch self {
                case .top: -1
                case .center: 0
                case .bottom: 1
                }
            }
        }
        public var y: Y
        
        @EnumMacro
        public enum Z: String, GraphicEnum {
            case far
            case center
            case near
            public var vector: Int {
                switch self {
                case .far: -1
                case .center: 0
                case .near: 1
                }
            }
        }
        public var z: Z
        
        public static let center = Alignment3D(x: .center, y: .center, z: .center)
        
        public init(x: X = .center, y: Y = .center, z: Z = .center) {
            self.x = x
            self.y = y
            self.z = z
        }
    }
    
    /// Horizontal Stack
    public func hStacked(
        with graphic: Graphic3D,
        yAlignment: Alignment3D.Y = .center,
        zAlignment: Alignment3D.Z = .center,
        spacing: Double = 0.0,
        padding: Double = 0.0,
        backgroundColor: PixelColor = .clear,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await stacked(
            with: graphic,
            axis: .horizontal,
            alignment: Alignment3D(x: .center, y: yAlignment, z: zAlignment),
            spacing: spacing,
            padding: padding,
            backgroundColor: backgroundColor,
            options: options
        )
    }
    
    /// Vertical Stack
    public func vStacked(
        with graphic: Graphic3D,
        xAlignment: Alignment3D.X = .center,
        zAlignment: Alignment3D.Z = .center,
        spacing: Double = 0.0,
        padding: Double = 0.0,
        backgroundColor: PixelColor = .clear,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await stacked(
            with: graphic,
            axis: .vertical,
            alignment: Alignment3D(x: xAlignment, y: .center, z: zAlignment),
            spacing: spacing,
            padding: padding,
            backgroundColor: backgroundColor,
            options: options
        )
    }
    
    /// Depth Stack
    public func dStacked(
        with graphic: Graphic3D,
        xAlignment: Alignment3D.X = .center,
        yAlignment: Alignment3D.Y = .center,
        spacing: Double = 0.0,
        padding: Double = 0.0,
        backgroundColor: PixelColor = .clear,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await stacked(
            with: graphic,
            axis: .depth,
            alignment: Alignment3D(x: xAlignment, y: yAlignment, z: .center),
            spacing: spacing,
            padding: padding,
            backgroundColor: backgroundColor,
            options: options
        )
    }
    
    private func stacked(
        with graphic: Graphic3D,
        axis: StackAxis,
        alignment: Alignment3D = .center,
        spacing: Double = 0.0,
        padding: Double = 0.0,
        backgroundColor: PixelColor = .clear,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let leadingResolution: Size3D = resolution
        let trailingResolution: Size3D = graphic.resolution
        
        let finalResolution: Size3D = switch axis {
        case .horizontal:
            Size3D(width: leadingResolution.width + trailingResolution.width + padding * 2 + spacing,
                   height: max(leadingResolution.height, trailingResolution.height) + padding * 2,
                   depth: max(leadingResolution.depth, trailingResolution.depth) + padding * 2)
        case .vertical:
            Size3D(width: max(leadingResolution.width, trailingResolution.width) + padding * 2,
                   height: leadingResolution.height + trailingResolution.height + padding * 2 + spacing,
                   depth: max(leadingResolution.depth, trailingResolution.depth) + padding * 2)
        case .depth:
            Size3D(width: max(leadingResolution.width, trailingResolution.width) + padding * 2,
                   height: max(leadingResolution.height, trailingResolution.height) + padding * 2,
                   depth: leadingResolution.depth + trailingResolution.depth + padding * 2 + spacing)
        }
        
        func leadingCenter() -> Point3D {
            switch axis {
            case .horizontal:
                Point3D(x: padding + leadingResolution.width / 2,
                        y: finalResolution.height / 2 + max(0.0, (trailingResolution.height / 2 - leadingResolution.height / 2)) * CGFloat(alignment.y.vector),
                        z: finalResolution.depth / 2 + max(0.0, (trailingResolution.depth / 2 - leadingResolution.depth / 2)) * CGFloat(alignment.z.vector))
            case .vertical:
                Point3D(x: finalResolution.width / 2 + max(0.0, (trailingResolution.width / 2 - leadingResolution.width / 2)) * CGFloat(alignment.x.vector),
                        y: padding + leadingResolution.height / 2,
                        z: finalResolution.depth / 2 + max(0.0, (trailingResolution.depth / 2 - leadingResolution.depth / 2)) * CGFloat(alignment.z.vector))
            case .depth:
                Point3D(x: finalResolution.width / 2 + max(0.0, (trailingResolution.width / 2 - leadingResolution.width / 2)) * CGFloat(alignment.x.vector),
                        y: finalResolution.height / 2 + max(0.0, (trailingResolution.height / 2 - leadingResolution.height / 2)) * CGFloat(alignment.y.vector),
                        z: padding + leadingResolution.depth / 2)
            }
        }
        let leadingCenter: Point3D = leadingCenter()
        
        func trailingCenter() -> Point3D {
            switch axis {
            case .horizontal:
                Point3D(x: finalResolution.width - padding - trailingResolution.width / 2,
                        y: finalResolution.height / 2 + max(0.0, (leadingResolution.height / 2 - trailingResolution.height / 2)) * CGFloat(alignment.y.vector),
                        z: finalResolution.depth / 2 + max(0.0, (leadingResolution.depth / 2 - trailingResolution.depth / 2)) * CGFloat(alignment.z.vector))
            case .vertical:
                Point3D(x: finalResolution.width / 2 + max(0.0, (leadingResolution.width / 2 - trailingResolution.width / 2)) * CGFloat(alignment.x.vector),
                        y: finalResolution.height - padding - trailingResolution.height / 2,
                        z: finalResolution.depth / 2 + max(0.0, (leadingResolution.depth / 2 - trailingResolution.depth / 2)) * CGFloat(alignment.z.vector))
            case .depth:
                Point3D(x: finalResolution.width / 2 + max(0.0, (leadingResolution.width / 2 - trailingResolution.width / 2)) * CGFloat(alignment.x.vector),
                        y: finalResolution.height / 2 + max(0.0, (leadingResolution.height / 2 - trailingResolution.height / 2)) * CGFloat(alignment.y.vector),
                        z: finalResolution.depth - padding - trailingResolution.depth / 2)
            }
        }
        let trailingCenter: Point3D = trailingCenter()
        
        let relativeLeadingCenter: Point3D = leadingCenter / finalResolution
        let relativeTrailingCenter: Point3D = trailingCenter / finalResolution
        let relativeLeadingSize: Size3D = leadingResolution / finalResolution
        let relativeTrailingSize: Size3D = trailingResolution / finalResolution
        
        return try await Renderer.render(
            name: "Stack 3D",
            shader: .name("stack3d"),
            graphics: [self, graphic],
            uniforms: Stack3DUniforms(
                backgroundColor: backgroundColor.uniform,
                leadingCenter: relativeLeadingCenter.uniform,
                leadingSize: relativeLeadingSize.uniform,
                trailingCenter: relativeTrailingCenter.uniform,
                trailingSize: relativeTrailingSize.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: finalResolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: options.renderOptions
        )
    }
}
