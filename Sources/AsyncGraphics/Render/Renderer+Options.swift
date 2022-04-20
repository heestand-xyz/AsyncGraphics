//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import Metal

extension Renderer {
    
    struct Options {
        var isArray: Bool = false
        var addressMode: MTLSamplerAddressMode = .clampToZero
    }
}
