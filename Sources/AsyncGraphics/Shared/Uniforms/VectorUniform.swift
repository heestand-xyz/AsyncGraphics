//
//  Created by Anton Heestand on 2022-04-05.
//

import simd

struct VectorUniform {
    
    let x: Float
    let y: Float
    let z: Float
}

extension VectorUniform {
    
    static let zero = VectorUniform(x: 0.0, y: 0.0, z: 0.0)
}

extension SIMD3 where Scalar == Double {
    
    var uniform: VectorUniform {
        VectorUniform(x: Float(x),
                      y: Float(y),
                      z: Float(z))
    }
}
