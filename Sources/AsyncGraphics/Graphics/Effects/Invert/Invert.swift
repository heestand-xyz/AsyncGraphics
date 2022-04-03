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
        
        let texture: MTLTexture = try await Renderer.render(
            shaderName: "invert",
            textures: [texture],
            resolution: resolution,
            bits: bits
        )
        
        return Graphic(texture: texture, bits: bits, colorSpace: colorSpace)
    }
}
