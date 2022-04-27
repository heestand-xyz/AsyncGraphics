//
//  Created by Anton Heestand on 2022-04-24.
//

import Foundation
import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct StackUniforms {
        let axis: Int32
        let alignment: Int32
        let spacing: Float
        let padding: Float
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }
    
    private enum StackAxis: Int {
        case horizontal = 0
        case vertical = 1
    }
    
    /// Vertical Stack Alignment
    public enum VStackAlignment: Int {
        case leading = -1
        case center = 0
        case trailing = 1
    }
    
    /// Horizontal Stack Alignment
    public enum HStackAlignment: Int {
        case bottom = -1
        case center = 0
        case top = 1
    }
    
    private enum StackAlignment: Int {
        case leftBottom = -1
        case center = 0
        case rightTop = 1
    }
    
    /// Vertical Stack
    public static func vStack(with graphics: [Graphic],
                              alignment: VStackAlignment = .center,
                              spacing: CGFloat = 0.0,
                              padding: CGFloat = 0.0,
                              backgroundColor: PixelColor = .black,
                              at graphicSize: CGSize? = nil) async throws -> Graphic {
        
        try await stack(with: graphics,
                        axis: .vertical,
                        alignment: StackAlignment(rawValue: alignment.rawValue)!,
                        spacing: spacing,
                        padding: padding,
                        backgroundColor: backgroundColor,
                        at: graphicSize)
    }
    
    /// Horizontal Stack
    public static func hStack(with graphics: [Graphic],
                              alignment: HStackAlignment = .center,
                              spacing: CGFloat = 0.0,
                              padding: CGFloat = 0.0,
                              backgroundColor: PixelColor = .black,
                              at graphicSize: CGSize? = nil) async throws -> Graphic {
        
        try await stack(with: graphics,
                        axis: .horizontal,
                        alignment: StackAlignment(rawValue: alignment.rawValue)!,
                        spacing: spacing,
                        padding: padding,
                        backgroundColor: backgroundColor,
                        at: graphicSize)
    }
    
    private static func stack(with graphics: [Graphic],
                              axis: StackAxis,
                              alignment: StackAlignment = .center,
                              spacing: CGFloat = 0.0,
                              padding: CGFloat = 0.0,
                              backgroundColor: PixelColor = .black,
                              at graphicSize: CGSize? = nil) async throws -> Graphic {
        
        let graphicSize: CGSize = graphicSize ?? {
            guard let size: CGSize = graphics.first?.size else { return .zero }
            let length: CGFloat = {
                switch axis {
                case .horizontal:
                    return size.width
                case .vertical:
                    return size.height
                }
            }()
            let adjacentLength: CGFloat = {
                switch axis {
                case .horizontal:
                    return size.height
                case .vertical:
                    return size.width
                }
            }()
            let totalLength: CGFloat = length * CGFloat(graphics.count) + spacing * CGFloat(graphics.count - 1) + padding * 2
            let totalAdjacentLength: CGFloat = adjacentLength + padding * 2
            return CGSize(width: axis == .horizontal ? totalLength : totalAdjacentLength,
                          height: axis == .vertical ? totalLength : totalAdjacentLength)
        }()
        
        let length: CGFloat = {
            switch axis {
            case .horizontal:
                return graphicSize.width
            case .vertical:
                return graphicSize.height
            }
        }()
        
        let relativeSpacing: CGFloat = spacing / length
        
        let relativePadding: CGFloat = padding / length
        
        let alignment: StackAlignment = axis == .vertical ? StackAlignment(rawValue: -alignment.rawValue)! : alignment
        
        return try await Renderer.render(
            name: "Stack",
            shader: .name("stack"),
            graphics: graphics,
            uniforms: StackUniforms(
                axis: Int32(axis.rawValue),
                alignment: Int32(alignment.rawValue),
                spacing: Float(relativeSpacing),
                padding: Float(relativePadding),
                backgroundColor: backgroundColor.uniform,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: graphicSize.resolution,
                colorSpace: graphics.first?.colorSpace ?? .sRGB,
                bits: graphics.first?.bits ?? ._8
            ),
            options: Renderer.Options(isArray: true)
        )
    }
}


extension Array where Element == Graphic {
    
    /// Vertical Stack
    public func vStack(alignment: Graphic.VStackAlignment = .center,
                       spacing: CGFloat = 0.0,
                       padding: CGFloat = 0.0,
                       backgroundColor: PixelColor = .black,
                       at graphicSize: CGSize? = nil) async throws -> Graphic {
        
        try await Graphic.vStack(with: self,
                                 alignment: alignment,
                                 spacing: spacing,
                                 padding: padding,
                                 backgroundColor: backgroundColor,
                                 at: graphicSize)
    }
    
    /// Horizontal Stack
    public func hStack(alignment: Graphic.HStackAlignment = .center,
                       spacing: CGFloat = 0.0,
                       padding: CGFloat = 0.0,
                       backgroundColor: PixelColor = .black,
                       at graphicSize: CGSize? = nil) async throws -> Graphic {
        
        try await Graphic.hStack(with: self,
                                 alignment: alignment,
                                 spacing: spacing,
                                 padding: padding,
                                 backgroundColor: backgroundColor,
                                 at: graphicSize)
    }
}
