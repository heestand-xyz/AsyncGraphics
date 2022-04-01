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
 
    static func image(_ image: TMImage) async -> AGTexture {
        
        let metalTexture: MTLTexture! = try? await image.texture
        
        let bits: TMBits = (try? image.bits) ?? ._8
        
        return AGTexture(metalTexture: metalTexture, bits: bits)
    }
    
    static func image(named name: String) async -> AGTexture {
        
        if let image = TMImage(named: name) {
            
            return await .image(image)
            
        } else {
            
            let resolution = LiveGraphics.fallbackResolution
            
            let metalTexture: MTLTexture! = try? await TextureMap.emptyTexture(size: resolution, bits: ._8)
            
            return AGTexture(metalTexture: metalTexture, bits: ._8)
        }
    }
}
