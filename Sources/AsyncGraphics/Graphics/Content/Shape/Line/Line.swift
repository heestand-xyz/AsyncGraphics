//
//  Created by Anton Heestand on 2023-04-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct LineUniforms {
        let premultiply: Bool
        let cap: UInt32
        let lineWidth: Float
        let leadingPoint: PointUniform
        let trailingPoint: PointUniform
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }
    
    @EnumMacro
    public enum LineCap: String, GraphicEnum {
        case square
        case round
        case diamond
    }
    
    public static func line(leadingPoint: CGPoint,
                            trailingPoint: CGPoint,
                            lineWidth: CGFloat = 1,
                            cap: LineCap = .square,
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            options: ContentOptions = []) async throws -> Graphic {

        let relativeLeadingPoint: CGPoint = (leadingPoint - resolution / 2) / resolution.height
        let relativeTrailingPoint: CGPoint = (trailingPoint - resolution / 2) / resolution.height
        
        let relativeLineWidth: CGFloat = lineWidth / resolution.height

        return try await Renderer.render(
            name: "Line",
            shader: .name("line"),
            uniforms: LineUniforms(
                premultiply: options.premultiply,
                cap: cap.index,
                lineWidth: Float(relativeLineWidth),
                leadingPoint: relativeLeadingPoint.uniform,
                trailingPoint: relativeTrailingPoint.uniform,
                foregroundColor: color.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                filter: options.filter
            )
        )
    }
}
