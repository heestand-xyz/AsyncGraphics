//
//  Created by Anton Heestand on 2022-04-27.
//

import PixelColor

extension Graphic3D {
    
    private struct ColorMap3DUniforms {
        let backgroundColor: ColorUniform
        let foregroundColor: ColorUniform
    }
    
    public func colorMap(
        from backgroundColor: PixelColor,
        to foregroundColor: PixelColor,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Color Map 3D",
            shader: .name("colorMap3d"),
            graphics: [self],
            uniforms: ColorMap3DUniforms(
                backgroundColor: backgroundColor.uniform,
                foregroundColor: foregroundColor.uniform),
            options: options.colorRenderOptions
        )
    }
}
