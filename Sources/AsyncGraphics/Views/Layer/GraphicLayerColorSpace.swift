//
//  GraphicLayerColorSpace.swift
//  AsyncGraphics
//

import CoreGraphics
import TextureMap

@MainActor
enum GraphicLayerColorSpace {
    static let standard = CGColorSpace(name: CGColorSpace.sRGB)!
    static let extended = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)!

    /// Reuse the original texture when no color conversion is needed.
    static func isPrepared(_ graphic: Graphic, extendedDynamicRange: Bool) -> Bool {
        if extendedDynamicRange {
            return graphic.colorSpace == .linearDisplayP3 || graphic.colorSpace == .custom(extended)
        }
        return graphic.colorSpace == .sRGB || graphic.colorSpace == .custom(standard)
    }

    /// Matches GraphicRepresentableView's XDR interpretation, including values above 1.
    static func source(for graphic: Graphic, extendedDynamicRange: Bool) -> CGColorSpace {
        guard extendedDynamicRange else { return graphic.colorSpace.cgColorSpace }
        switch graphic.colorSpace {
        case .nonLinearSRGB:
            return CGColorSpace(name: CGColorSpace.extendedSRGB)!
        case .linearSRGB:
            return CGColorSpace(name: CGColorSpace.extendedLinearSRGB)!
        default:
            return graphic.colorSpace.cgColorSpace
        }
    }
}
