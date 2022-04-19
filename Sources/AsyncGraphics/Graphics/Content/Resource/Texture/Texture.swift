//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal
import TextureMap

extension Graphic {
    
    public enum TextureGraphicError: LocalizedError {
        
        case unsupportedType
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedType:
                return "AsyncGraphics - Graphic - Texture - Unsupported Type"
            }
        }
    }
    
    public static func texture(_ texture: MTLTexture, colorSpace: TMColorSpace = .sRGB) throws -> Graphic {
        
        guard texture.textureType == .type2D else {
            throw TextureGraphicError.unsupportedType
        }
        
        let bits = try TMBits(texture: texture)
        
        return Graphic(name: "Texture", texture: texture, bits: bits, colorSpace: colorSpace)
    }
}
