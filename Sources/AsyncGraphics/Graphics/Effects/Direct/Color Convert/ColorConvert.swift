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
    
    public enum ColorConversion: String, Codable, CaseIterable, Identifiable {
        case rgbToHSV
        case hsvToRGB
        public var id: String { rawValue } 
        var index: UInt32 {
            switch self {
            case .rgbToHSV:
                return 0
            case .hsvToRGB:
                return 1
            }
        }
    }
    
    public enum ColorConvertChannel: String, Codable, CaseIterable, Identifiable {
        case all
        case first
        case second
        case third
        public var id: String { rawValue }
        var index: UInt32 {
            switch self {
            case .all:
                return 0
            case .first:
                return 1
            case .second:
                return 2
            case .third:
                return 3
            }
        }
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
                conversion: conversion.index,
                index: channel.index
            )
        )
    }
}
