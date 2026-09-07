//
//  GraphicMetalLayerDisplayDelegate.swift
//  AsyncGraphics
//

import QuartzCore

@MainActor
final class GraphicMetalLayerDisplayDelegate: NSObject, CALayerDelegate {
    private weak var graphicLayer: GraphicMetalLayer?
    private nonisolated let layerID: ObjectIdentifier

    init(layer: GraphicMetalLayer) {
        graphicLayer = layer
        layerID = ObjectIdentifier(layer)
        super.init()
    }

    nonisolated func display(_ layer: CALayer) {
        // Only the view-owned model layer renders, synchronously on the UI actor.
        // Core Animation can copy this delegate onto a presentation layer.
        guard ObjectIdentifier(layer) == layerID else { return }
        MainActor.assumeIsolated { graphicLayer?.render() }
    }
}
