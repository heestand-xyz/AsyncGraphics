//
//  Created by Anton Heestand on 2022-04-05.
//

import CoreGraphics

struct SizeUniform {
    
    let width: Float
    let height: Float
}

extension CGSize {
    
    var uniform: SizeUniform {
        SizeUniform(width: Float(width),
                    height: Float(height))
    }
}
