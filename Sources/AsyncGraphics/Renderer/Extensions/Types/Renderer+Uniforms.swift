//
//  Created by Anton Heestand on 2022-04-20.
//

import Spatial

extension Renderer {
    
    struct EmptyUniforms {}
}

extension Renderer {

    struct CameraUniforms {
        let projectionMatrix: matrix_float4x4
        let modelViewMatrix: matrix_float4x4
    }
}
