//
//  Created by Anton Heestand on 2022-04-03.
//

import Foundation
import Metal
import TextureMap

public extension Graphic {
    
    func blended(graphic: Graphic, blendingMode: BlendingMode, placement: Placement) async throws -> Graphic {
        
        let texture: MTLTexture = try await Renderer.render(
            shaderName: "blend",
            textures: [
                texture,
                graphic.texture
            ],
            uniforms: [
                blendingMode.index,
                placement.index,
            ],
            resolution: resolution,
            bits: bits
        )
        
        return Graphic(texture: texture, bits: bits, colorSpace: colorSpace)
    }
}
