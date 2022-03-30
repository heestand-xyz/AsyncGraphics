//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

extension Texture {
    
    func inverted() async -> Texture {
        
        let emptyTexture: MTLTexture! = await withCheckedContinuation { continuation in
            
            let emptyTexture: MTLTexture! = try? TextureMap.emptyTexture(size: LiveGraphics.fallbackResolution, bits: ._8)
            
            continuation.resume(returning: emptyTexture)
        }
        
        return Texture(rawTexture: emptyTexture)
    }
}
