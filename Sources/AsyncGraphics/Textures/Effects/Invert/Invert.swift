//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

public extension AGGraphic {
    
    func inverted() async throws -> AGGraphic {
        
        let texture: MTLTexture = try await AGRenderer.render(as: "invert", texture: metalTexture, bits: bits)
        
        return AGGraphic(metalTexture: texture, bits: bits, colorSpace: colorSpace)
    }
}
