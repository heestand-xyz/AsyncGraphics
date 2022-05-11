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
        
        var texture: MTLTexture = try await image.texture
        
        texture = try await texture.convertColorSpace(from: CGColorSpace(name: CGColorSpace.linearSRGB)!,
                                                      to: colorSpace.cgColorSpace)
        
        return Graphic(name: "Image", texture: texture, bits: bits, colorSpace: colorSpace)
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
