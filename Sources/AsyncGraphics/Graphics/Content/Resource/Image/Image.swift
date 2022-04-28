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

extension Graphic {
    
    /// UIImage / NSImage
    public static func image(_ image: TMImage) async throws -> Graphic {
        
        let bits: TMBits = try image.bits
        
        let colorSpace: TMColorSpace = try image.colorSpace
        print("IMAGE COLOR SPACE", colorSpace)
        
        var texture: MTLTexture = try await image.texture
        
        texture = try await texture.convertColorSpace(from: CGColorSpace(name: CGColorSpace.linearSRGB)!,
                                                      to: colorSpace.cgColorSpace)
        
        return Graphic(name: "Image", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
    public static func image(named name: String, in bundle: Bundle = .main) async throws -> Graphic {
        
        let image = try bundle.image(named: name)
            
        return try await .image(image)
    }
}
