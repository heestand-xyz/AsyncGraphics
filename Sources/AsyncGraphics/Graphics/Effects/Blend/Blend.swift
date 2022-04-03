//
//  Created by Anton Heestand on 2022-04-03.
//

import Foundation
import Metal
import TextureMap

public extension Graphic {
    
    func blended(graphic: Graphic, with blendingMode: BlendingMode, at placement: Placement) async throws -> Graphic {
        
        let texture: MTLTexture = try await Renderer.render(
            as: "blend",
            textures: [
                metalTexture,
                graphic.metalTexture
            ],
            uniforms: [
                blendingMode.index,
                placement.index,
            ],
            bits: bits
        )
        
        return Graphic(metalTexture: texture, bits: bits, colorSpace: colorSpace)
    }
}
