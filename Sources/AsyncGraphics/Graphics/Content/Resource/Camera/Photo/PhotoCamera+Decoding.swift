//
//  PhotoCamera+Decoding.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS) || os(macOS)
import AVFoundation
import CoreImage
import Metal
import TextureMap
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Graphic.PhotoCamera {
    func decodePhoto(_ data: Data, preserveHDR: Bool, position: AVCaptureDevice.Position) async throws -> Graphic {
        let graphic: Graphic
        if preserveHDR {
            guard let image: CIImage = CIImage(data: data, options: [
                .applyOrientationProperty: true,
                .expandToHDR: true
            ]), let colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3) else {
                throw PhotoCameraError.noImageCapture
            }
            let texture: MTLTexture = try .empty(resolution: image.extent.size, bits: ._16, usage: .write)
            let context: CIContext = CIContext(mtlDevice: Renderer.metalDevice)
            context.render(image, to: texture, commandBuffer: nil, bounds: image.extent, colorSpace: colorSpace)
            // Rendered in extended range to keep values above 1.0, tagged as linear Display P3
            // so the graphic can be encoded, like the OpenEXR stored for high bit bindings.
            let decoded: Graphic = Graphic(name: "Photo", texture: texture, bits: ._16, colorSpace: .linearDisplayP3)
            // Core Image's origin differs from Graphic's; EXIF rotation has already
            // been applied by the decoder and must not be applied again.
            graphic = try await decoded.mirroredVertically()
        } else {
            guard let image: TMImage = TMImage(data: data) else { throw PhotoCameraError.noImageCapture }
            graphic = try await .image(image)
        }
        // Mirror in the final, oriented image space, for both single and bracketed
        // photos. Focus coordinates remain in the unmirrored capture space.
        return position == .front ? try await graphic.mirroredHorizontally() : graphic
    }
}
#endif
