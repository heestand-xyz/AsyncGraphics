//
//  LiveFrame.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal

struct LiveFrame {
    
    let texture: MTLTexture!
    
    var resolution: CGSize {
        texture.size
    }
}

extension LiveFrame: Equatable {
    
    static func == (lhs: LiveFrame, rhs: LiveFrame) -> Bool {
        
        guard lhs.resolution == rhs.resolution else {
            return false
        }
        
        return lhs.texture.hash == rhs.texture.hash
    }
}

//extension LiveFrame: Comparable {
//    
//}
