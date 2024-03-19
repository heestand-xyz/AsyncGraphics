//
//  Created by Anton Heestand on 2022-04-24.
//

import Foundation
import Spatial
import PixelColor

extension Graphic3D {
    
    private struct Stack3DUniforms {
        let axis: Int32
        let xAlignment: Int32
        let yAlignment: Int32
        let zAlignment: Int32
        let spacing: Float
        let padding: Float
        let backgroundColor: ColorUniform
        let resolution: VectorUniform
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
    public func hStacked(with graphic: Graphic3D,
                         yAlignment: Alignment3D.Y = .center,
                         zAlignment: Alignment3D.Z = .center,
                         spacing: Double = 0.0,
                         padding: Double = 0.0,
                         backgroundColor: PixelColor = .clear,
                         resolution: Size3D? = nil) async throws -> Graphic3D {
        
        try await stacked(with: graphic,
                          axis: .horizontal,
                          alignment: Alignment3D(x: .center, y: yAlignment, z: zAlignment),
                          spacing: spacing,
                          padding: padding,
                          backgroundColor: backgroundColor,
                          resolution: resolution)
    }
    
    /// Vertical Stack
    public func vStacked(with graphic: Graphic3D,
                         xAlignment: Alignment3D.X = .center,
                         zAlignment: Alignment3D.Z = .center,
                         spacing: Double = 0.0,
                         padding: Double = 0.0,
                         backgroundColor: PixelColor = .clear,
                         resolution: Size3D? = nil) async throws -> Graphic3D {
        
        try await stacked(with: graphic,
                          axis: .vertical,
                          alignment: Alignment3D(x: xAlignment, y: .center, z: zAlignment),
                          spacing: spacing,
                          padding: padding,
                          backgroundColor: backgroundColor,
                          resolution: resolution)
    }
    
    /// Depth Stack
    public func dStacked(with graphic: Graphic3D,
                         xAlignment: Alignment3D.X = .center,
                         yAlignment: Alignment3D.Y = .center,
                         spacing: Double = 0.0,
                         padding: Double = 0.0,
                         backgroundColor: PixelColor = .clear,
                         resolution: Size3D? = nil) async throws -> Graphic3D {
        
        try await stacked(with: graphic,
                          axis: .depth,
                          alignment: Alignment3D(x: xAlignment, y: yAlignment, z: .center),
                          spacing: spacing,
                          padding: padding,
                          backgroundColor: backgroundColor,
                          resolution: resolution)
    }
    
    private func stacked(with graphic: Graphic3D,
                         axis: StackAxis,
                         alignment: Alignment3D = .center,
                         spacing: Double = 0.0,
                         padding: Double = 0.0,
                         backgroundColor: PixelColor = .clear,
                         resolution: Size3D? = nil) async throws -> Graphic3D {
        
        let graphics: [Graphic3D] = [self, graphic]
        
        let finalResolution: Size3D
        if let resolution: Size3D {
            finalResolution = resolution
        } else {
            let resolution: Size3D = graphics.first!.resolution
            let length: Double = {
                switch axis {
                case .horizontal:
                    return resolution.width
                case .vertical:
                    return resolution.height
                case .depth:
                    return resolution.depth
                }
            }()
            let totalLength: Double = length * Double(graphics.count) + spacing * Double(graphics.count - 1) + padding * 2.0
            let totalAdjacentSize: Size3D = Size3D(
                width: resolution.width + padding * 2.0,
                height: resolution.height + padding * 2.0,
                depth: resolution.depth + padding * 2.0)
            finalResolution = Size3D(
                width: axis == .horizontal ? totalLength : totalAdjacentSize.width,
                height: axis == .vertical ? totalLength : totalAdjacentSize.height,
                depth: axis == .depth ? totalLength : totalAdjacentSize.depth)
        }
        
        let length: Double = {
            switch axis {
            case .horizontal:
                return finalResolution.width
            case .vertical:
                return finalResolution.height
            case .depth:
                return finalResolution.depth
            }
        }()
        
        let relativeSpacing: Double = spacing / length
        
        let relativePadding: Double = padding / length
        
        return try await Renderer.render(
            name: "Stack 3D",
            shader: .name("stack3d"),
            graphics: graphics,
            uniforms: Stack3DUniforms(
                axis: Int32(axis.rawValue),
                xAlignment: Int32(alignment.x.vector),
                yAlignment: Int32(alignment.y.vector),
                zAlignment: Int32(alignment.z.vector),
                spacing: Float(relativeSpacing),
                padding: Float(relativePadding),
                backgroundColor: backgroundColor.uniform,
                resolution: finalResolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: finalResolution,
                colorSpace: graphics.first?.colorSpace ?? .sRGB,
                bits: graphics.first?.bits ?? ._8
            )
        )
    }
}
