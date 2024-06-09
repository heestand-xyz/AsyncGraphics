//
//  Created by Anton Heestand on 2022-04-20.
//

import Metal

extension Renderer {
    
    enum Shader: Hashable {
        case name(String)
        case custom(fragment: String, vertex: String)
        case code(String, name: String)
        case camera(String)
        case passthrough
    }
}

extension Renderer.Shader {
    
    var fragmentName: String {
        switch self {
        case .name(let name):
            return name
        case .custom(let name, _):
            return name
        case .code(_, let name):
            return name
        case .camera(let name):
            return name
        case .passthrough:
            return "fragmentPassthrough"
        }
    }
    
    var vertexName: String {
        switch self {
        case .custom(_, let vertex):
            return vertex
        case .camera:
            return "vertexCamera"
        default:
            return "vertexPassthrough"
        }
    }
}
