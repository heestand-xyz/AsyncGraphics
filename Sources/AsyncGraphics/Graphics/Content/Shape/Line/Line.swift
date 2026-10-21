//
//  Created by Anton Heestand on 2023-04-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct LineUniforms: Uniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let cap: UInt32
        let lineWidth: Float
        let leadingPoint: PointUniform
        let trailingPoint: PointUniform
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }
    
    @EnumMacro
    public enum LineCap: String, GraphicEnum {
        case square
        case round
        case diamond
    }
    
    @available(*, deprecated, renamed: "line(from:to:lineWidth:cap:color:backgroundColor:resolution:tile:options:)")
    public static func line(leadingPoint: CGPoint,
                            trailingPoint: CGPoint,
                            lineWidth: CGFloat = 1.0,
                            cap: LineCap = .square,
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            tile: Tile = .one,
                            options: ContentOptions = []) async throws -> Graphic {
        try await .line(
            from: leadingPoint,
            to: trailingPoint,
            lineWidth: lineWidth,
            cap: cap,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            tile: tile,
            options: options
        )
    }
    
    public static func line(from leadingPoint: CGPoint,
                            to trailingPoint: CGPoint,
                            lineWidth: CGFloat = 1.0,
                            cap: LineCap = .square,
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            tile: Tile = .one,
                            options: ContentOptions = []) async throws -> Graphic {

        let relativeLeadingPoint: CGPoint = (leadingPoint - resolution / 2) / resolution.height
        let relativeTrailingPoint: CGPoint = (trailingPoint - resolution / 2) / resolution.height
        
        let relativeLineWidth: CGFloat = lineWidth / resolution.height

        return try await Renderer.render(
            name: "Line",
            shader: .name("line"),
            uniforms: LineUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                cap: cap.index,
                lineWidth: Float(relativeLineWidth),
                leadingPoint: relativeLeadingPoint.uniform,
                trailingPoint: relativeTrailingPoint.uniform,
                foregroundColor: color.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }

    /// An open polyline with optional rounded bends and conventional stroke caps.
    /// Points and stroke dimensions are expressed in output pixels.
    public static func line(points: [CGPoint],
                            cornerRadius: CGFloat = 0.0,
                            stroke: StrokeStyle = StrokeStyle(),
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            tile: Tile = .one,
                            options: ContentOptions = []) async throws -> Graphic {
        let path = try roundedPolylinePath(points: points, cornerRadius: cornerRadius, closed: false)
        return try await .path(path,
                               stroke: stroke,
                               color: color,
                               backgroundColor: backgroundColor,
                               resolution: resolution,
                               tile: tile,
                               options: options)
    }
}
