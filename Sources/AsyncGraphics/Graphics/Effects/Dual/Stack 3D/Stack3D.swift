//
//  Created by Anton Heestand on 2022-04-24.
//

import Foundation
import simd
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
    
    /// Vertical Stack Alignment
    public enum VStackAlignment {
        case leadingFar
        case leadingNear
        case leading
        case center
        case trailing
        case trailingNear
        case trailingFar
    }
    
    /// Horizontal Stack Alignment
    public enum HStackAlignment {
        case bottomFar
        case bottomNear
        case bottom
        case center
        case top
        case topNear
        case topFar
    }
    
    /// Depth Stack Alignment
    public enum DStackAlignment {
        case bottomTrailing
        case bottomLeading
        case bottom
        case center
        case top
        case topLeading
        case topTrailing
    }
    
    private enum StackAlignment {
        
        case center
        case leading
        case leadingNear
        case leadingFar
        case trailing
        case trailingNear
        case trailingFar
        case bottom
        case bottomLeading
        case bottomTrailing
        case bottomNear
        case bottomFar
        case top
        case topLeading
        case topTrailing
        case topNear
        case topFar
        
        init(alignment: VStackAlignment) {
            switch alignment {
            case .leadingFar:
                self = .leadingFar
            case .leadingNear:
                self = .leadingNear
            case .leading:
                self = .leading
            case .center:
                self = .center
            case .trailing:
                self = .trailing
            case .trailingNear:
                self = .trailingNear
            case .trailingFar:
                self = .trailingFar
            }
        }
        
        init(alignment: HStackAlignment) {
            switch alignment {
            case .bottomFar:
                self = .bottomFar
            case .bottomNear:
                self = .bottomNear
            case .bottom:
                self = .bottom
            case .center:
                self = .center
            case .top:
                self = .top
            case .topNear:
                self = .topNear
            case .topFar:
                self = .topFar
            }
        }
        
        init(alignment: DStackAlignment) {
            switch alignment {
            case .bottomTrailing:
                self = .bottomTrailing
            case .bottomLeading:
                self = .bottomLeading
            case .bottom:
                self = .bottom
            case .center:
                self = .center
            case .top:
                self = .top
            case .topLeading:
                self = .topLeading
            case .topTrailing:
                self = .topTrailing
            }
        }
        
        var xIndex: Int {
            switch self {
            case .leading, .leadingFar, .leadingNear, .bottomLeading, .topLeading:
                return -1
            case .trailing, .trailingNear, .trailingFar, .bottomTrailing, .topTrailing:
                return 1
            default:
                return 0
            }
        }
        
        var yIndex: Int {
            switch self {
            case .bottom, .bottomLeading, .bottomTrailing, .bottomNear, .bottomFar:
                return -1
            case .top, .topLeading, .topTrailing, .topNear, .topFar:
                return 1
            default:
                return 0
            }
        }
        
        var zIndex: Int {
            switch self {
            case .leadingNear, .trailingNear, .bottomNear, .topNear:
                return -1
            case .leadingFar, .trailingFar, .bottomFar, .topFar:
                return 1
            default:
                return 0
            }
        }
    }
    
    /// Vertical Stack
    public func vStack(with graphic: Graphic3D,
                       alignment: VStackAlignment = .center,
                       spacing: Double = 0.0,
                       padding: Double = 0.0,
                       backgroundColor: PixelColor = .black,
                       resolution: SIMD3<Int>? = nil) async throws -> Graphic3D {
        
        try await stack(with: graphic,
                        axis: .vertical,
                        alignment: StackAlignment(alignment: alignment),
                        spacing: spacing,
                        padding: padding,
                        backgroundColor: backgroundColor,
                        resolution: resolution)
    }
    
    /// Horizontal Stack
    public func hStack(with graphic: Graphic3D,
                       alignment: HStackAlignment = .center,
                       spacing: Double = 0.0,
                       padding: Double = 0.0,
                       backgroundColor: PixelColor = .black,
                       resolution: SIMD3<Int>? = nil) async throws -> Graphic3D {
        
        try await stack(with: graphic,
                        axis: .horizontal,
                        alignment: StackAlignment(alignment: alignment),
                        spacing: spacing,
                        padding: padding,
                        backgroundColor: backgroundColor,
                        resolution: resolution)
    }
    
    /// Depth Stack
    public func dStack(with graphic: Graphic3D,
                       alignment: DStackAlignment = .center,
                       spacing: Double = 0.0,
                       padding: Double = 0.0,
                       backgroundColor: PixelColor = .black,
                       resolution: SIMD3<Int>? = nil) async throws -> Graphic3D {
        
        try await stack(with: graphic,
                        axis: .depth,
                        alignment: StackAlignment(alignment: alignment),
                        spacing: spacing,
                        padding: padding,
                        backgroundColor: backgroundColor,
                        resolution: resolution)
    }
    
    private func stack(with graphic: Graphic3D,
                       axis: StackAxis,
                       alignment: StackAlignment = .center,
                       spacing: Double = 0.0,
                       padding: Double = 0.0,
                       backgroundColor: PixelColor = .black,
                       resolution: SIMD3<Int>? = nil) async throws -> Graphic3D {
        
        let graphics: [Graphic3D] = [self, graphic]
        
        let resolution: SIMD3<Int> = resolution ?? {
            let resolution: SIMD3<Int> = graphics.first!.resolution
            let length: Double = {
                switch axis {
                case .horizontal:
                    return Double(resolution.x)
                case .vertical:
                    return Double(resolution.y)
                case .depth:
                    return Double(resolution.z)
                }
            }()
            let adjacentSize: SIMD3<Double> = resolution.asDouble
            let totalLength: Double = length * Double(graphics.count) + spacing * Double(graphics.count - 1) + padding * 2
            let totalAdjacentSize: SIMD3<Double> = adjacentSize + padding * 2
            return SIMD3<Int>(axis == .horizontal ? Int(totalLength) : Int(totalAdjacentSize.x),
                              axis == .vertical ? Int(totalLength) : Int(totalAdjacentSize.y),
                              axis == .depth ? Int(totalLength) : Int(totalAdjacentSize.z))
        }()
        
        let length: Double = {
            switch axis {
            case .horizontal:
                return Double(resolution.x)
            case .vertical:
                return Double(resolution.y)
            case .depth:
                return Double(resolution.z)
            }
        }()
        
        let relativeSpacing: Double = spacing / length
        
        let relativePadding: Double = padding / length
        
        return try await Renderer.render(
            name: "Stack",
            shader: .name("stack3d"),
            graphics: graphics,
            uniforms: Stack3DUniforms(
                axis: Int32(axis.rawValue),
                xAlignment: Int32(alignment.xIndex),
                yAlignment: Int32(alignment.yIndex),
                zAlignment: Int32(alignment.zIndex),
                spacing: Float(relativeSpacing),
                padding: Float(relativePadding),
                backgroundColor: backgroundColor.uniform,
                resolution: resolution.asDouble.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: graphics.first?.colorSpace ?? .sRGB,
                bits: graphics.first?.bits ?? ._8
            )
        )
    }
}
