//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

public extension AGTexture {
    
    func inverted() async throws -> AGTexture {
        
        let texture: MTLTexture = try await AGRenderer.render(as: "invert", texture: metalTexture, bits: bits)
        
        return AGTexture(metalTexture: texture, bits: bits, colorSpace: colorSpace)
    }
}
