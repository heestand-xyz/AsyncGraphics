//
//  Created by Anton Heestand on 2022-04-11.
//

import Metal
import TextureMap

protocol Graphicable: Sendable {
    
    var id: UUID { get }
    
    var name: String { get }

    var texture: MTLTexture { get }
    
    var bits: TMBits { get }
    var colorSpace: TMColorSpace { get }
        
    init(id: UUID, name: String, texture: MTLTexture, bits: TMBits, colorSpace: TMColorSpace)
}
