//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap

extension Graphic {
    
    public struct Options: OptionSet {
        
        public let rawValue: Int
        
        /// 16 bit rendering
        public static let highBitMode = Options(rawValue: 1)
        
        var bits: TMBits {
            contains(.highBitMode) ? ._16 : ._8
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
