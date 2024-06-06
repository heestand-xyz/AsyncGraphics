import MetalKit
import Foundation
import TextureMap

extension Graphic {
    
    public func mapTexture(
        _ transform: (MTLTexture) async throws -> MTLTexture
    ) async throws -> Graphic {
        
        let texture: MTLTexture = try await transform(texture)
        
        let bits: TMBits = try TMBits(texture: texture)
        
        return Graphic(
            name: "Map Texture",
            texture: texture,
            bits: bits,
            colorSpace: colorSpace
        )
    }
}

extension Graphic {
    
    public func mapImage(
        _ transform: (TMImage) async throws -> TMImage
    ) async throws -> Graphic {
        try await .image(transform(image))
    }
}
