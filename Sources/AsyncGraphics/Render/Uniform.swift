//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics

protocol Uniform {
    
    var floats: [CGFloat] { get }
}

extension CGFloat: Uniform {
    
    var floats: [CGFloat] { [self] }
}

extension CGPoint: Uniform {
    
    var floats: [CGFloat] { [x, y] }
}

extension CGSize: Uniform {
    
    var floats: [CGFloat] { [width, height] }
}
