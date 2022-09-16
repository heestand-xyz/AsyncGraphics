//
//  Created by Anton Heestand on 2022-04-19.
//

import CoreGraphics
import PixelColor
import SwiftUI

extension Graphic {
    
    private struct ColorConvertUniforms {
        let conversion: UInt32
        let index: UInt32
    }
    
    public enum ColorConversion: UInt32 {
        case rgbToHSV
        case hsvToRGB
    }
    
    public enum ColorConvertChannel: UInt32 {
        case all
        case first
        case second
        case third
    }
    
    public func colorConvert(
        _ conversion: ColorConversion,
        channel: ColorConvertChannel = .all
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Color Convert",
            shader: .name("colorConvert"),
            graphics: [self],
            uniforms: ColorConvertUniforms(
                conversion: conversion.rawValue,
                index: channel.rawValue
            )
        )
    }
}
