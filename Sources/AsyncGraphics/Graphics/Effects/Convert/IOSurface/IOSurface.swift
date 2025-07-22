//
//  IOSurface.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-07-22.
//

import Foundation
import TextureMap
import IOSurface

extension Graphic {
    
    /// Copies the `texture` with a new `iosurface` if not already present.
    public func withIOSurface() async throws -> (Graphic, IOSurfaceRef) {
        let (newTexture, iosurface) = try await TextureMap.textureWithIOSurface(texture: texture)
        let newGraphic = Graphic(
            name: "IO Surface",
            texture: newTexture,
            bits: bits,
            colorSpace: colorSpace
        )
        return (newGraphic, iosurface)
    }
}
