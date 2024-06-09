//
//  Created by Anton Heestand on 2022-09-13.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct ChromaKeyUniforms {
        let premultiply: Bool
        let keyColor: ColorUniform
        let range: Float
        let softness: Float
        let edgeDesaturation: Float
        let alphaCrop: Float
    }
    
    public struct ChromaKeyParameters {
        public var range: CGFloat = 0.1
        public var softness: CGFloat = 0.1
        public var edgeDesaturation: CGFloat = 0.5
        public var alphaCrop: CGFloat = 0.5
        public init() {}
    }
    
    /// Chroma Key (Green Screen)
    ///
    /// Remove backgrounds of footage that has a colored background.
    /// - Parameters:
    ///   - range: The amount of background that will be removed. *(Fraction from 0.0 to 1.0, default at 0.1)*
    ///   - softness: The fade of the edge of the removed background. *(Fraction from 0.0 to 1.0, default at 0.1)*
    ///   - edgeDesaturation: The amount of desaturation to the edges. *(Fraction from 0.0 to 1.0, default at 0.5)*
    ///   - alphaCrop: A alpha crop factor. *(Fraction from 0.0 to 1.0, default at 0.5)*
    public func chromaKey(
        color: PixelColor = .rawGreen,
        parameters: ChromaKeyParameters = ChromaKeyParameters(),
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "ChromaKey",
            shader: .name("chromaKey"),
            graphics: [self],
            uniforms: ChromaKeyUniforms(
                premultiply: options.premultiply,
                keyColor: color.uniform,
                range: Float(parameters.range),
                softness: Float(parameters.softness),
                edgeDesaturation: Float(parameters.edgeDesaturation),
                alphaCrop: Float(parameters.alphaCrop)
            ),
            options: options.colorRenderOptions
        )
    }
}
