//
//  AGTexture.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

struct AGTexture {
    
    let metalTexture: MTLTexture!
    
    let bits: TMBits
    
    var resolution: CGSize {
        metalTexture.size
    }
}

extension AGTexture: Equatable {
    
    static func == (lhs: AGTexture, rhs: AGTexture) -> Bool {
        
        guard lhs.resolution == rhs.resolution else {
            return false
        }
        
        return lhs.metalTexture.hash == rhs.metalTexture.hash
    }
}

//extension AGTexture: Comparable {
//    
//}
