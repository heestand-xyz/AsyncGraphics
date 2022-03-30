//
//  Texture.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal

struct Texture {
    
    let rawTexture: MTLTexture!
    
    var resolution: CGSize {
        rawTexture.size
    }
}

extension Texture: Equatable {
    
    static func == (lhs: Texture, rhs: Texture) -> Bool {
        
        guard lhs.resolution == rhs.resolution else {
            return false
        }
        
        return lhs.rawTexture.hash == rhs.rawTexture.hash
    }
}

//extension Texture: Comparable {
//    
//}
