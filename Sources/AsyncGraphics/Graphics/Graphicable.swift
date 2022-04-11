//
//  Created by Anton Heestand on 2022-04-11.
//

import Metal
import TextureMap

protocol Graphicable {
    
    var name: String { get }

    var texture: MTLTexture { get }
    
    var bits: TMBits { get }
    var colorSpace: TMColorSpace { get }
        
    init(name: String, texture: MTLTexture, bits: TMBits, colorSpace: TMColorSpace)
}
