//
//  PhotoCamera+Decoding.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS)
import CoreImage
import Metal
import TextureMap
import UIKit

extension Graphic.PhotoCamera {
    func decodePhoto(_ data: Data, preserveHDR: Bool) async throws -> Graphic {
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
            let graphic: Graphic = Graphic(name: "Photo", texture: texture, bits: ._16, colorSpace: .custom(colorSpace))
            // Core Image's origin differs from Graphic's; EXIF rotation has already
            // been applied by the decoder and must not be applied again.
            return try await graphic.mirroredVertically()
        }
        guard let image: UIImage = UIImage(data: data) else { throw PhotoCameraError.noImageCapture }
        return try await .image(image)
    }
}
#endif
