//
//  File.swift
//  
//
//  Created by Anton Heestand on 2024-06-08.
//

import TextureMap

extension Graphic {
    
    public func copy() async throws -> Graphic {
        Graphic(
            name: "\(name) (Copy)",
            texture: try await texture.copy(),
            bits: bits,
            colorSpace: colorSpace
        )
    }
}
