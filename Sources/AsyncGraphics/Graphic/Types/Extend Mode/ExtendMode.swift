//
//  ExtendMode.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/02/16.
//

import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    @EnumMacro
    public enum ExtendMode: String, GraphicEnum {
        case zero
        case loop
        case mirror
        case stretch
    }
}

extension Graphic.ExtendMode {
    
    var options: Graphic.EffectOptions {
        switch self {
        case .zero: []
        case .loop: .edgeLoop
        case .mirror: .edgeMirror
        case .stretch: .edgeStretch
        }
    }
    
    var options3D: Graphic3D.EffectOptions {
        switch self {
        case .zero: []
        case .loop: .edgeLoop
        case .mirror: .edgeMirror
        case .stretch: .edgeStretch
        }
    }
}
