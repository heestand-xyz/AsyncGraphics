//
//  Created by Anton Heestand on 2022-04-20.
//

import Metal

extension Renderer {
    
    enum Shader {
        case name(String)
        case custom(fragment: String, vertex: String)
        case code(String, name: String)
    }
}
