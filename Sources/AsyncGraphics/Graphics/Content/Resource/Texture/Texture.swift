//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal
import TextureMap

public extension Graphic {
    
    static func texture(_ texture: MTLTexture, colorSpace: TMColorSpace = .sRGB) throws -> Graphic {
        
        let bits = try TMBits(texture: texture)
        
        return Graphic(name: "Texture", texture: texture, bits: bits, colorSpace: colorSpace)
    }
}
