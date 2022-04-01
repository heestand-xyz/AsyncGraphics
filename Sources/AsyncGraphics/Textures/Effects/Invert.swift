//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap
//import Logger

public extension AGTexture {
    
    func inverted() async -> AGTexture {
        
        let texture: MTLTexture! = try? await AGRenderer.render(as: "invert", texture: metalTexture, bits: bits)
        
        return AGTexture(metalTexture: texture, bits: bits)
    }
}
