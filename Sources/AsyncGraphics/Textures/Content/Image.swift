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

public extension AGTexture {
    
    static func image(_ image: TMImage) async throws -> AGTexture {
        
        let metalTexture: MTLTexture = try await image.texture
        
        let bits: TMBits = try image.bits
        
        let colorSpace: TMColorSpace = try image.colorSpace
        
        return AGTexture(metalTexture: metalTexture, bits: bits, colorSpace: colorSpace)
    }
    
    static func image(named name: String, in bundle: Bundle = .main) async throws -> AGTexture {
        
        let image = try bundle.image(named: name)
            
        return try await .image(image)
    }
}
