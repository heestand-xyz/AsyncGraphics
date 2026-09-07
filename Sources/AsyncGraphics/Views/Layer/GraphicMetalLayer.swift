//
//  GraphicMetalLayer.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-07.
//

import Metal
import QuartzCore

@MainActor
final class GraphicMetalLayer: CAMetalLayer {
    private let resources: GraphicMetalLayerResources
    private var graphic: Graphic?
    private let colorConversion: GraphicLayerColorConversion
    private var interpolate = true
    private var extendedDynamicRange = false
    private var isAttached = false

    override init() {
        resources = GraphicMetalLayerResources.shared
        colorConversion = GraphicLayerColorConversion()
        super.init()
        device = Renderer.metalDevice
        pixelFormat = .bgra8Unorm
        colorspace = GraphicLayerColorSpace.standard
        framebufferOnly = true
        presentsWithTransaction = true
        isOpaque = false
        needsDisplayOnBoundsChange = true
    }

    override init(layer: Any) {
        guard let layer = layer as? GraphicMetalLayer else {
            fatalError("GraphicMetalLayer: Expected a graphic layer when copying.")
        }
        resources = layer.resources
        colorConversion = GraphicLayerColorConversion()
        // Presentation copies inherit the drawable, but never own graphic state.
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("GraphicMetalLayer: init(coder:) is unsupported.")
    }

    func update(graphic: Graphic, interpolate: Bool, extendedDynamicRange: Bool) {
        let colorSpaceChanged = self.extendedDynamicRange != extendedDynamicRange
        let graphicChanged = self.graphic != graphic
        let interpolationChanged = self.interpolate != interpolate
        guard graphicChanged || colorSpaceChanged || interpolationChanged else { return }
        self.graphic = graphic
        self.interpolate = interpolate
        if colorSpaceChanged {
            colorConversion.reset()
            self.extendedDynamicRange = extendedDynamicRange
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            pixelFormat = extendedDynamicRange ? .rgba16Float : .bgra8Unorm
            colorspace = extendedDynamicRange ? GraphicLayerColorSpace.extended : GraphicLayerColorSpace.standard
#if !os(tvOS)
            wantsExtendedDynamicRangeContent = extendedDynamicRange
#endif
            CATransaction.commit()
        }
        setNeedsDisplay()
    }

    func setIsAttached(_ attached: Bool) {
        guard isAttached != attached else { return }
        isAttached = attached
        if attached {
            setNeedsDisplay()
        }
    }

    func dismantle() {
        isAttached = false
        colorConversion.reset()
        graphic = nil
    }

    func render() {
        guard isAttached, let graphic,
              bounds.width > 0, bounds.height > 0,
              drawableSize.width > 0, drawableSize.height > 0 else { return }
#if DEBUG
        let interval = AGPerformanceTrace.presentation.begin("Graphic layer draw sync")
        defer { AGPerformanceTrace.presentation.end(interval) }
#endif
        // Drawables can be unavailable while a view is offscreen.
        guard let drawable = nextDrawable() else { return }
        guard let commandBuffer = resources.commandQueue.makeCommandBuffer() else {
            assertionFailure("GraphicMetalLayer: Could not create a command buffer.")
            return
        }
        commandBuffer.label = "GraphicMetalLayer: Draw Graphic"
        let texture = colorConversion.texture(
            for: graphic,
            extendedDynamicRange: extendedDynamicRange,
            commandBuffer: commandBuffer
        )
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .dontCare
        descriptor.colorAttachments[0].storeAction = .store
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            colorConversion.reset()
            assertionFailure("GraphicMetalLayer: Could not create a render encoder.")
            return
        }
        encoder.setRenderPipelineState(extendedDynamicRange ? resources.extendedPipeline : resources.standardPipeline)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentSamplerState(interpolate ? resources.linearSampler : resources.nearestSampler, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
#if DEBUG
        AGPerformanceTrace.presentation.trackGPU(commandBuffer, detail: "Graphic layer \(drawableSize.width)x\(drawableSize.height)")
#endif
        commandBuffer.commit()
        // Match GraphMetalLayer: synchronize with layout, without waiting for GPU completion.
        commandBuffer.waitUntilScheduled()
        drawable.present()
    }
}
