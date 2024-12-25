//
//  SendableTexture.swift
//  AsyncGraphics
//
//  Created by Anton on 2024-12-24.
//

import Metal

struct SendableTexture: @unchecked Sendable {
    
    private let texture: MTLTexture
    
    fileprivate init(texture: MTLTexture) {
        self.texture = texture
    }
}

extension SendableTexture {
    func receive() -> MTLTexture {
        texture
    }
}

extension MTLTexture {
    func send() -> SendableTexture {
        SendableTexture(texture: self)
    }
}
