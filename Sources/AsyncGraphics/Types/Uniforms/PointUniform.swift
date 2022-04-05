//
//  Created by Anton Heestand on 2022-04-05.
//

import CoreGraphics

struct PointUniform {
    let x: Float
    let y: Float
}

extension CGPoint {
    
    var uniform: PointUniform {
        PointUniform(x: Float(x),
                     y: Float(y))
    }
}
