//
//  Created by Anton Heestand on 2022-05-23.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct GradientUniforms {
        let type: Int32
        let extend: Int32
        let scale: Float
        let offset: Float
        let position: PointUniform
        let gamma: Float
        let premultiply: Bool
        let resolution: SizeUniform
    }
    
    private struct GradientColorStopUniforms {
        let fraction: Float
        let color: ColorUniform
    }
    
    /// Gradient Stop is a color with a location between 0.0 and 1.0
    public struct GradientStop {
        /// A location between 0.0 and 1.0
        public var location: CGFloat
        public var color: PixelColor
        public init(at location: CGFloat, color: PixelColor) {
            self.location = location
            self.color = color
        }
    }
    
    public enum GradientDirection: Int32 {
        case horizontal
        case vertical
        case radial
        case angle
    }
    
    public enum GradientExtend: Int32 {
        case zero
        case hold
        case loop
        case mirror
    }
    
    public static func gradient(direction: GradientDirection,
                                stops: [GradientStop] = [
                                    GradientStop(at: 0.0, color: .black),
                                    GradientStop(at: 1.0, color: .white)
                                ],
                                position: CGPoint = .zero,
                                scale: CGFloat = 1.0,
                                offset: CGFloat = 0.0,
                                extend: GradientExtend = .zero,
                                gamma: CGFloat = 1.0,
                                resolution: CGSize,
                                options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Gradient",
            shader: .name("gradient"),
            uniforms: GradientUniforms(
                type: direction.rawValue,
                extend: extend.rawValue,
                scale: Float(scale),
                offset: Float(offset),
                position: position.uniform,
                gamma: Float(gamma),
                premultiply: true,
                resolution: resolution.uniform
            ),
            arrayUniforms: stops.map { stop in
                GradientColorStopUniforms(
                    fraction: Float(stop.location),
                    color: stop.color.uniform
                )
            },
            emptyArrayUniform: GradientColorStopUniforms(
                fraction: 0.0,
                color: PixelColor.clear.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
