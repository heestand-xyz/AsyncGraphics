//
//  Created by Anton Heestand on 2022-04-05.
//

import simd

struct VectorUniform {
    
    let x: Float
    let y: Float
    let z: Float
}

extension SIMD3 where Scalar == Double {
    
    var uniform: VectorUniform {
        VectorUniform(x: Float(x),
                      y: Float(y),
                      z: Float(z))
    }
}
