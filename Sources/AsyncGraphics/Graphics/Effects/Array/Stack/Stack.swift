//
//  Created by Anton Heestand on 2022-04-24.
//

import Foundation
import CoreGraphics
import PixelColor

extension Graphic {
    
    enum StackError: LocalizedError {
        case noGraphicsProvided
        var errorDescription: String? {
            switch self {
            case .noGraphicsProvided:
                return "Async Graphics - Stack - No Graphics Provided"
            }
        }
    }
    
    private struct StackUniforms {
        let axis: Int32
        let alignment: Int32
        let spacing: Float
        let padding: Float
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }
    
    enum StackAxis: Int {
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
    
    // MARK: VStack
    
    /// Vertical Stack
    public static func vStacked(with graphics: [Graphic],
                                alignment: VStackAlignment = .center) async throws -> Graphic {
        
        guard !graphics.isEmpty else {
            throw StackError.noGraphicsProvided
        }
        
        var stackGraphic: Graphic = graphics.first!
        
        for graphic in graphics.dropFirst() {
            stackGraphic = try await stackGraphic.vStacked(with: graphic, alignment: alignment)
        }
        
        return stackGraphic
    }
    
    @available(*, deprecated, renamed: "vStackedFixed")
    public static func vStack(with graphics: [Graphic],
                              alignment: VStackAlignment = .center,
                              spacing: CGFloat,
                              padding: CGFloat,
                              backgroundColor: PixelColor = .black,
                              resolution: CGSize? = nil) async throws -> Graphic {
        
        try await vStackedFixed(with: graphics,
                                alignment: alignment,
                                spacing: spacing,
                                padding: padding,
                                backgroundColor: backgroundColor,
                                resolution: resolution)
    }
    
    /// Vertical Stack Fixed
    ///
    /// This stack requires all graphics to have the same resolution.
    public static func vStackedFixed(with graphics: [Graphic],
                                     alignment: VStackAlignment = .center,
                                     spacing: CGFloat = 0.0,
                                     padding: CGFloat = 0.0,
                                     backgroundColor: PixelColor = .black,
                                     resolution: CGSize? = nil) async throws -> Graphic {
        
        try await stackedFixed(with: graphics,
                               axis: .vertical,
                               alignment: StackAlignment(rawValue: alignment.rawValue)!,
                               spacing: spacing,
                               padding: padding,
                               backgroundColor: backgroundColor,
                               resolution: resolution)
    }
    
    /// Horizontal Stack
    public static func hStacked(with graphics: [Graphic],
                                alignment: HStackAlignment = .center) async throws -> Graphic {
        
        guard !graphics.isEmpty else {
            throw StackError.noGraphicsProvided
        }
        
        var stackGraphic: Graphic = graphics.first!
        
        for graphic in graphics.dropFirst() {
            stackGraphic = try await stackGraphic.hStacked(with: graphic, alignment: alignment)
        }
        
        return stackGraphic
    }
    
    // MARK: HStack
    
    @available(*, deprecated, renamed: "hStackedFixed")
    public static func hStack(with graphics: [Graphic],
                              alignment: HStackAlignment = .center,
                              spacing: CGFloat,
                              padding: CGFloat,
                              backgroundColor: PixelColor = .black,
                              resolution: CGSize? = nil) async throws -> Graphic {
        
        try await hStackedFixed(with: graphics,
                                alignment: alignment,
                                spacing: spacing,
                                padding: padding,
                                backgroundColor: backgroundColor,
                                resolution: resolution)
    }
    
    /// Horizontal Stack Fixed
    ///
    /// This stack requires all graphics to have the same resolution.
    public static func hStackedFixed(with graphics: [Graphic],
                                     alignment: HStackAlignment = .center,
                                     spacing: CGFloat = 0.0,
                                     padding: CGFloat = 0.0,
                                     backgroundColor: PixelColor = .black,
                                     resolution: CGSize? = nil) async throws -> Graphic {
        
        try await stackedFixed(with: graphics,
                               axis: .horizontal,
                               alignment: StackAlignment(rawValue: alignment.rawValue)!,
                               spacing: spacing,
                               padding: padding,
                               backgroundColor: backgroundColor,
                               resolution: resolution)
    }
    
    // MARK: Stack
    
    private static func stackedFixed(with graphics: [Graphic],
                                     axis: StackAxis,
                                     alignment: StackAlignment = .center,
                                     spacing: CGFloat = 0.0,
                                     padding: CGFloat = 0.0,
                                     backgroundColor: PixelColor = .black,
                                     resolution: CGSize? = nil) async throws -> Graphic {
        
        let resolution: CGSize = resolution ?? {
            guard let resolution: CGSize = graphics.first?.resolution else { return .zero }
            let length: CGFloat = {
                switch axis {
                case .horizontal:
                    return resolution.width
                case .vertical:
                    return resolution.height
                }
            }()
            let adjacentLength: CGFloat = {
                switch axis {
                case .horizontal:
                    return resolution.height
                case .vertical:
                    return resolution.width
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
                return resolution.width
            case .vertical:
                return resolution.height
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
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: graphics.first?.colorSpace ?? .sRGB,
                bits: graphics.first?.bits ?? ._8
            ),
            options: Renderer.Options(isArray: true)
        )
    }
}


extension Array where Element == Graphic {
    
    /// Vertical Stack
    public func vStacked(alignment: Graphic.VStackAlignment = .center) async throws -> Graphic {
        
        try await Graphic.vStacked(with: self,
                                   alignment: alignment)
    }
    
    /// Vertical Stack
    @available(*, deprecated, renamed: "vStackedFixed")
    public func vStack(alignment: Graphic.VStackAlignment = .center,
                       spacing: CGFloat = 0.0,
                       padding: CGFloat = 0.0,
                       backgroundColor: PixelColor = .black,
                       resolution: CGSize? = nil) async throws -> Graphic {
        
        try await Graphic.vStack(with: self,
                                 alignment: alignment,
                                 spacing: spacing,
                                 padding: padding,
                                 backgroundColor: backgroundColor,
                                 resolution: resolution)
    }
    
    /// Horizontal Stack
    public func hStacked(alignment: Graphic.HStackAlignment = .center) async throws -> Graphic {
        
        try await Graphic.hStacked(with: self,
                                   alignment: alignment)
    }
    
    /// Horizontal Stack
    @available(*, deprecated, renamed: "hStackedFixed")
    public func hStack(alignment: Graphic.HStackAlignment = .center,
                       spacing: CGFloat = 0.0,
                       padding: CGFloat = 0.0,
                       backgroundColor: PixelColor = .black,
                       resolution: CGSize? = nil) async throws -> Graphic {
        
        try await Graphic.hStack(with: self,
                                 alignment: alignment,
                                 spacing: spacing,
                                 padding: padding,
                                 backgroundColor: backgroundColor,
                                 resolution: resolution)
    }
}
