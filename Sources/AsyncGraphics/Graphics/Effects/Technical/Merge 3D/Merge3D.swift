//
//  Created by Anton Heestand on 2022-04-13.
//

import TextureMap
import Metal

enum ArrayMergeError: LocalizedError {
    
    case emptyArray
    
    var errorDescription: String? {
        switch self {
        case .emptyArray:
            return "AsyncGraphics - Merge - Empty Array"
        }
    }
}

public extension Array where Element == Graphic {
    
    func merge() async throws -> Graphic3D {
        
        guard !isEmpty else {
            throw ArrayMergeError.emptyArray
        }
        
        let texture: MTLTexture = try await map(\.texture).texture(type: .type3D)
        
        return Graphic3D(name: "Merge", texture: texture, bits: first!.bits, colorSpace: first!.colorSpace)
    }
}
