//
//  GraphicLayerColorConversion.swift
//  AsyncGraphics
//

import Foundation
import CoreGraphics
import Metal
import MetalPerformanceShaders
import TextureMap

/// Reuses color conversion resources. All writes and sampling are submitted to
/// GraphicMetalLayerResources' single queue, so the texture can be reused in order.
@MainActor
final class GraphicLayerColorConversion {
    private var sourceColorSpace: TMColorSpace?
    private var targetColorSpace: CGColorSpace?
    private var conversion: MPSImageConversion?
    private var convertedTexture: MTLTexture?
    private var convertedGraphicID: UUID?

    func reset() {
        sourceColorSpace = nil
        targetColorSpace = nil
        conversion = nil
        convertedTexture = nil
        convertedGraphicID = nil
    }

    func texture(for graphic: Graphic, extendedDynamicRange: Bool, commandBuffer: MTLCommandBuffer) -> MTLTexture {
        guard GraphicLayerView.isColorConversionEnabled else {
            // Release the conversion resources while the feature is disabled.
            if conversion != nil { reset() }
            return graphic.texture
        }
        if GraphicLayerColorSpace.isPrepared(graphic, extendedDynamicRange: extendedDynamicRange) {
            // Release a conversion texture when the source no longer needs it.
            if conversion != nil { reset() }
            return graphic.texture
        }
        let target = extendedDynamicRange ? GraphicLayerColorSpace.extended : GraphicLayerColorSpace.standard
        if sourceColorSpace != graphic.colorSpace || targetColorSpace != target {
            let source = GraphicLayerColorSpace.source(for: graphic, extendedDynamicRange: extendedDynamicRange)
            let info = CGColorConversionInfo(src: source, dst: target)
            conversion = MPSImageConversion(
                device: Renderer.metalDevice,
                srcAlpha: .premultiplied,
                destAlpha: .premultiplied,
                backgroundColor: nil,
                conversionInfo: info
            )
            sourceColorSpace = graphic.colorSpace
            targetColorSpace = target
            convertedGraphicID = nil
        }
        if convertedTexture?.width != graphic.texture.width ||
            convertedTexture?.height != graphic.texture.height ||
            convertedTexture?.pixelFormat != graphic.texture.pixelFormat {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: graphic.texture.pixelFormat,
                width: graphic.texture.width,
                height: graphic.texture.height,
                mipmapped: false
            )
            descriptor.storageMode = .private
            descriptor.usage = [.shaderRead, .shaderWrite]
            guard let texture = Renderer.metalDevice.makeTexture(descriptor: descriptor) else {
                preconditionFailure("GraphicLayerColorConversion: Could not create a conversion texture.")
            }
            convertedTexture = texture
            convertedGraphicID = nil
        }
        guard let conversion, let convertedTexture else {
            preconditionFailure("GraphicLayerColorConversion: Missing conversion resources.")
        }
        if convertedGraphicID != graphic.id {
            conversion.encode(commandBuffer: commandBuffer, sourceTexture: graphic.texture, destinationTexture: convertedTexture)
            convertedGraphicID = graphic.id
        }
        return convertedTexture
    }
}
