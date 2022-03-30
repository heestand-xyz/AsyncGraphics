//
//  Texture.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

struct Texture {
    
    let metalTexture: MTLTexture!
    
    let bits: TMBits
    
    var resolution: CGSize {
        metalTexture.size
    }
}

extension Texture: Equatable {
    
    static func == (lhs: Texture, rhs: Texture) -> Bool {
        
        guard lhs.resolution == rhs.resolution else {
            return false
        }
        
        return lhs.metalTexture.hash == rhs.metalTexture.hash
    }
}

//extension Texture: Comparable {
//    
//}
