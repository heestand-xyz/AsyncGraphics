//
//  Invert.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import Metal
import TextureMap

extension Graphic {
    
    public func inverted() async throws -> Graphic {
        
        try await Renderer.render(
            name: "Invert",
            shaderName: "invert",
            graphics: [self]
        )
    }
}
