//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap
import Logger

extension AGTexture {
    
    func inverted() async -> AGTexture {
        
        let texture: MTLTexture! = await withCheckedContinuation { continuation in
            
            let renderer = Renderer()
            let texture: MTLTexture!
            do {
                texture = try renderer.render(as: "invert", texture: metalTexture, bits: bits)
            } catch {
                Logger.log(.error(error), message: "Render Failed", frequency: .verbose)
            }
            
            continuation.resume(returning: texture)
        }
        
        return AGTexture(metalTexture: texture, bits: bits)
    }
}
