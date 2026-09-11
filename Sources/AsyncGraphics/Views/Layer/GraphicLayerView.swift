//
//  GraphicLayerView.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-07.
//

import SwiftUI

public struct GraphicLayerView: View {
    
    /// Color convert the graphic to the layer's color space before it is drawn.
    ///
    /// A graphic whose color space already matches the layer is drawn directly.
    /// Every other graphic is converted with an `MPSImageConversion` pass on each drawn frame.
    ///
    /// Disabled while the cost of that per frame pass is being evaluated.
    /// A graphic in a different color space is drawn with its raw channels until this is enabled.
    public nonisolated(unsafe) static var isColorConversionEnabled: Bool = true
    
    private let graphic: Graphic
    /// Linear interpolation when `true`, pixelated when `false`.
    private let interpolate: Bool
    private let extendedDynamicRange: Bool
    
    /// Graphic Metal Layer View backed by CAMetalLayer
    /// - Parameters:
    ///   - graphic: A graphic.
    ///   - interpolate: Linear interpolation when `true`, pixelated when `false`.
    ///   - extendedDynamicRange: Render as XDR on supported displays when graphic is 16 or 32 bit.
    public init(
        graphic: Graphic,
        interpolate: Bool = true,
        extendedDynamicRange: Bool = true
    ) {
        self.graphic = graphic
        self.interpolate = interpolate
        self.extendedDynamicRange = extendedDynamicRange
    }
    
    public var body: some View {
        GraphicMetalLayerRepresentable(
            graphic: graphic,
            interpolate: interpolate,
            extendedDynamicRange: extendedDynamicRange && graphic.bits != ._8
        )
        .aspectRatio(graphic.resolution, contentMode: .fit)
    }
}
