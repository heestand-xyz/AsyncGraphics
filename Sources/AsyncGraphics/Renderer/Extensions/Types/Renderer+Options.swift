//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import Metal
import PixelColor

extension Renderer {
    
    struct Options {
        var isArray: Bool = false
        var addressMode: MTLSamplerAddressMode = .clampToZero
        var filter: MTLSamplerMinMagFilter = .linear
        var clearColor: PixelColor = .clear
        var additive: Bool = false
        var sampleCount: Int = 1
    }
}
