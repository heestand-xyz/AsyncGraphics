//
//  Created by Anton Heestand on 2022-04-11.
//

import Metal
import TextureMap

protocol Graphicable {

    var texture: MTLTexture { get }
    
    var bits: TMBits { get }
    var colorSpace: TMColorSpace { get }
    
    associatedtype R
    var resolution: R { get }
    
    init(texture: MTLTexture, bits: TMBits, colorSpace: TMColorSpace)
}
