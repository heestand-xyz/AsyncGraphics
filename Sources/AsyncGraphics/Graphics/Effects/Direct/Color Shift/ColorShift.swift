//
//  Created by Anton Heestand on 2022-04-19.
//

import CoreGraphics
import PixelColor
import SwiftUI

extension Graphic {
    
    private struct ColorShiftUniforms {
        let hue: Float
        let saturation: Float
        let tintColor: ColorUniform
    }
    
    public func monochrome() async throws -> Graphic {
        
        try await saturated(0.0)
    }
    
    /// `1.0` is *default*
    public func saturated(_ saturation: CGFloat) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Saturation",
            shader: .name("colorShift"),
            graphics: [self],
            uniforms: ColorShiftUniforms(
                hue: 0.0,
                saturation: Float(saturation),
                tintColor: PixelColor.white.uniform
            )
        )
    }
    
    /// `0.0` is *default*, `0.5` is `180` degrees of hue shift
    public func hue(_ hue: Angle) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Hue",
            shader: .name("colorShift"),
            graphics: [self],
            uniforms: ColorShiftUniforms(
                hue: hue.uniform,
                saturation: 1.0,
                tintColor: PixelColor.white.uniform
            )
        )
    }
    
    public func tinted(_ color: PixelColor) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Tint",
            shader: .name("colorShift"),
            graphics: [self],
            uniforms: ColorShiftUniforms(
                hue: 0.0,
                saturation: 1.0,
                tintColor: color.uniform
            )
        )
    }
}
