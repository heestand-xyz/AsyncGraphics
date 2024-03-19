//
//  Created by Anton Heestand on 2022-04-05.
//

import Spatial
import SpatialExtensions

struct VectorUniform {
    
    let x: Float
    let y: Float
    let z: Float
}

extension VectorUniform {
    
    static let zero = VectorUniform(x: 0.0, y: 0.0, z: 0.0)
}

extension Vector3D {
    
    var uniform: VectorUniform {
        VectorUniform(x: Float(x),
                      y: Float(y),
                      z: Float(z))
    }
}

extension Point3D {
    
    var uniform: VectorUniform {
        VectorUniform(x: Float(x),
                      y: Float(y),
                      z: Float(z))
    }
}

extension Size3D {
    
    var uniform: VectorUniform {
        VectorUniform(x: Float(width),
                      y: Float(height),
                      z: Float(depth))
    }
}

extension Angle3D {
    
    var uniform: VectorUniform {
        VectorUniform(x: Float(x.radians),
                      y: Float(y.radians),
                      z: Float(z.radians))
    }
}
