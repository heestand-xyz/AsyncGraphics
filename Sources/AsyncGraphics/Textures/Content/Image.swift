//
//  Image.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
import CoreGraphicsExtensions
import Metal
import TextureMap

extension AGTexture {
 
    static func image(_ image: TMImage) async -> AGTexture {
        
        let metalTexture: MTLTexture! = await try? image.texture
        
        let bits: TMBits = (try? image.bits) ?? ._8
        
        return AGTexture(metalTexture: metalTexture, bits: bits)
    }
    
    static func image(named name: String) async -> AGTexture {
        
        if let image = TMImage(named: name) {
            
            return .image(image)
            
        } else {
            
            let resolution = LiveGraphics.fallbackResolution
            
            let metalTexture: MTLTexture! = await try? TextureMap.emptyTexture(size: resolution, bits: ._8)
            
            return AGTexture(metalTexture: metalTexture, bits: ._8)
        }
    }
}
