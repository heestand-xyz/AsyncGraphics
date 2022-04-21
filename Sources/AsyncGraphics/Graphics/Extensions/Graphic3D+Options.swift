//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap

extension Graphic3D {
    
    public struct Options: OptionSet {
        
        public let rawValue: Int
        
        /// 16 bit rendering
        public static let highBit = Options(rawValue: 1)
        
        var bits: TMBits {
            contains(.highBit) ? ._16 : ._8
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
