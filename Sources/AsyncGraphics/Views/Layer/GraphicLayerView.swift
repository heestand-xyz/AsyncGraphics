//
//  GraphicLayerView.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-07.
//

import SwiftUI

public struct GraphicLayerView: View {
    
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
