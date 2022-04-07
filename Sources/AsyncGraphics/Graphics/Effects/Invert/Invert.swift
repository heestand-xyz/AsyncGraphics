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
        
        try await Renderer.render(
            shaderName: "invert",
            graphics: [self]
        )
    }
}
