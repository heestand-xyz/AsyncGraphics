//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics

protocol Uniform {
    var size: Int { get }
}

extension Bool: Uniform {
    var size: Int { MemoryLayout<Bool>.size }
}

extension Int: Uniform {
    var size: Int { MemoryLayout<Int>.size }
}

extension CGFloat: Uniform {
    var size: Int { MemoryLayout<CGFloat>.size }
}

extension CGPoint: Uniform {
    var size: Int { MemoryLayout<CGPoint>.size }
}

extension CGSize: Uniform {
    var size: Int { MemoryLayout<CGSize>.size }
}
