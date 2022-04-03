//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

public extension Graphic {
    
    func inverted() async throws -> Graphic {
        
        let texture: MTLTexture = try await Renderer.render(as: "invert", texture: metalTexture, bits: bits)
        
        return Graphic(metalTexture: texture, bits: bits, colorSpace: colorSpace)
    }
}
