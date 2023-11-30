//
//  Created by Anton Heestand on 2022-04-19.
//

import CoreGraphics
import PixelColor
import SwiftUI

extension Graphic3D {
    
    private struct ColorShift3DUniforms {
        let hue: Float
        let saturation: Float
        let tintColor: ColorUniform
    }
    
    public func monochrome() async throws -> Graphic3D {
        
        try await saturated(0.0)
    }
    
    /// `1.0` is *default*
    public func saturated(_ saturation: CGFloat) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Saturation 3D",
            shader: .name("colorShift3d"),
            graphics: [self],
            uniforms: ColorShift3DUniforms(
                hue: 0.0,
                saturation: Float(saturation),
                tintColor: PixelColor.white.uniform
            )
        )
    }
    
    /// `0.0` is *default*, `0.5` is `180` degrees of hue shift
    public func hue(_ hue: Angle) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Hue 3D",
            shader: .name("colorShift3d"),
            graphics: [self],
            uniforms: ColorShift3DUniforms(
                hue: hue.uniform,
                saturation: 1.0,
                tintColor: PixelColor.white.uniform
            )
        )
    }
    
    public func tinted(_ color: PixelColor) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Tint 3D",
            shader: .name("colorShift3d"),
            graphics: [self],
            uniforms: ColorShift3DUniforms(
                hue: 0.0,
                saturation: 1.0,
                tintColor: color.uniform
            )
        )
    }
    
    func colorShift(hue: Angle = .zero,
                    saturation: CGFloat = 1.0,
                    tint color: PixelColor = .white) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Color Shift",
            shader: .name("colorShift3d"),
            graphics: [self],
            uniforms: ColorShift3DUniforms(
                hue: hue.uniform,
                saturation: Float(saturation),
                tintColor: color.uniform
            )
        )
    }
}
