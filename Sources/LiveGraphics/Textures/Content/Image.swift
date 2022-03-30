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

extension Texture {
 
    init(image: TMImage) async {
        
        rawTexture = await withCheckedContinuation { continuation in
            let texture = try? image.texture
            continuation.resume(returning: texture)
        }
    }
    
    init(named name: String) async {
        
        if let image = TMImage(named: name) {
            
            rawTexture = await withCheckedContinuation { continuation in
                
                let texture = try? image.texture
                
                continuation.resume(returning: texture)
            }
            
        } else {
            
            let resolution = LiveGraphics.fallbackResolution
            
            rawTexture = await withCheckedContinuation { continuation in
                
                let emptyTexture = try? TextureMap.emptyTexture(size: resolution, bits: ._8)
                
                continuation.resume(returning: emptyTexture)
            }
        }
    }
}
