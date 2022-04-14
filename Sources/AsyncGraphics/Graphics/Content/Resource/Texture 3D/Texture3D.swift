//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal
import TextureMap

public extension Graphic3D {
    
    enum TextureGraphic3DError: LocalizedError {
        
        case unsupportedType
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedType:
                return "AsyncGraphics - Graphic - Texture - Unsupported Type"
            }
        }
    }
    
    static func texture(_ texture: MTLTexture, colorSpace: TMColorSpace = .sRGB) throws -> Graphic3D {
        
        guard texture.textureType == .type3D else {
            throw TextureGraphic3DError.unsupportedType
        }
        
        let bits = try TMBits(texture: texture)
        
        return Graphic3D(name: "Texture", texture: texture, bits: bits, colorSpace: colorSpace)
    }
}
