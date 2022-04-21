//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap

extension Graphic3D {
    
    public struct Options {
        
        let bits: TMBits
        
        public init(bits: TMBits = ._8) {
            self.bits = bits
        }
    }
}
