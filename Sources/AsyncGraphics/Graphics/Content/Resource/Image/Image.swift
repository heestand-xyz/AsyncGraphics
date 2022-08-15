//
//  Image.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
import Metal
import TextureMap
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

extension Graphic {
    
    enum ImageError: LocalizedError {
        
        case imageNotFound
        
        var errorDescription: String? {
            switch self {
            case .imageNotFound:
                return "AsyncGraphics - Image - Not Found"
            }
        }
    }
    
    /// UIImage / NSImage
    public static func image(_ image: TMImage) async throws -> Graphic {
        
        
        
        let bits: TMBits = try image.bits
        
        let colorSpace: TMColorSpace = try image.colorSpace
        let isMonochrome = image.cgImage?.colorSpace?.model == .monochrome
        
        var texture: MTLTexture = try await image.texture
        
//        texture = try await texture.convertColorSpace(from: CGColorSpace(name: CGColorSpace.linearSRGB)!,
//                                                      to: colorSpace.cgColorSpace)
        
        var graphic = Graphic(name: "Image", texture: texture, bits: bits, colorSpace: colorSpace)
        
        if isMonochrome {
            graphic = try await graphic.monochrome()
        }
        
        #if os(iOS)
        graphic = try await graphic.rotate(to: image.imageOrientation)
        #endif
        
        return graphic
    }
    
    public static func image(named name: String, in bundle: Bundle = .main) async throws -> Graphic {
        
        let image = try bundle.image(named: name)
        
        return try await .image(image)
    }
    
    public static func image(url: URL) async throws -> Graphic {
        
        let data = try Data(contentsOf: url)
        
        guard let image = TMImage(data: data) else {
            throw ImageError.imageNotFound
        }
        
        return try await .image(image)
    }
}

extension Graphic {
    
    #if os(iOS)
    private func rotate(to orientation: UIImage.Orientation) async throws -> Graphic {
        switch orientation {
        case .down, .downMirrored:
            return try await rotatedLeft().rotatedLeft()
        case .left, .leftMirrored:
            return try await rotatedLeft()
        case .right, .rightMirrored:
            return try await rotatedRight()
        case .up, .upMirrored:
            return self
        @unknown default:
            return self
        }
    }
    #endif
}
