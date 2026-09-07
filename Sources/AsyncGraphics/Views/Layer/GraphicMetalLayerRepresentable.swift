//
//  GraphicMetalLayerRepresentable.swift
//  AsyncGraphics
//

import SwiftUI

struct GraphicMetalLayerRepresentable {
    let graphic: Graphic
    let interpolate: Bool
    let extendedDynamicRange: Bool
}

#if os(macOS)
extension GraphicMetalLayerRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> GraphicMetalLayerView {
        GraphicMetalLayerView(frame: .zero)
    }

    func updateNSView(_ view: GraphicMetalLayerView, context: Context) {
        view.update(graphic: graphic, interpolate: interpolate, extendedDynamicRange: extendedDynamicRange)
    }

    static func dismantleNSView(_ view: GraphicMetalLayerView, coordinator: ()) {
        view.dismantle()
    }
}
#else
// MARK: - UIKit

extension GraphicMetalLayerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> GraphicMetalLayerView {
        GraphicMetalLayerView(frame: .zero)
    }

    func updateUIView(_ view: GraphicMetalLayerView, context: Context) {
        view.update(graphic: graphic, interpolate: interpolate, extendedDynamicRange: extendedDynamicRange)
    }

    static func dismantleUIView(_ view: GraphicMetalLayerView, coordinator: ()) {
        view.dismantle()
    }
}
#endif
