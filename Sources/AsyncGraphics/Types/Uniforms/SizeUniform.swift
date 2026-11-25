//
//  Created by Anton Heestand on 2022-04-05.
//

import CoreGraphics

struct SizeUniform: Uniforms {
    
    let width: Float
    let height: Float
}

extension SizeUniform {
    
    static let zero = SizeUniform(width: 0.0, height: 0.0)
    static let one = SizeUniform(width: 1.0, height: 1.0)
}

extension CGSize {
    
    /// Match the integer dimensions used by the Metal texture descriptor.
    var pixelDimensionsUniform: SizeUniform {
        SizeUniform(width: Float(width.rounded(.towardZero)),
                    height: Float(height.rounded(.towardZero)))
    }

    var uniform: SizeUniform {
        SizeUniform(width: Float(width),
                    height: Float(height))
    }
}
