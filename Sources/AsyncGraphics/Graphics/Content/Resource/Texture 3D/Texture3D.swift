//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal
import TextureMap

extension Graphic3D {
    
    public enum Texture3DError: LocalizedError {
        
        case unsupportedType
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedType:
                return "AsyncGraphics - Graphic3D - Texture - Unsupported Type"
            }
        }
    }
    
    public static func texture(_ texture: MTLTexture) throws -> Graphic3D {
        
        guard texture.textureType == .type3D else {
            throw Texture3DError.unsupportedType
        }
        
        let bits = try TMBits(texture: texture)
        
        return Graphic3D(name: "Texture", texture: texture, bits: bits, colorSpace: .sRGB)
    }
}
