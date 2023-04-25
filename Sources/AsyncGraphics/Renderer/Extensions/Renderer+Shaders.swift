//
//  Created by Anton Heestand on 2022-04-20.
//

import Metal

extension Renderer {
    
    static func shader(name: String) throws -> MTLFunction {
        guard let metalLibrary else {
            throw RendererError.metalLibraryNotFound
        }
        guard let shader = metalLibrary.makeFunction(name: name) else {
            throw RendererError.shaderFunctionNotFound(name: name)
        }
        return shader
    }
    
    static func shader(name: String, code: String) throws -> MTLFunction {
        let metalLibrary: MTLLibrary = try metalDevice.makeLibrary(source: code, options: nil)
        guard let shader = metalLibrary.makeFunction(name: name) else {
            throw RendererError.shaderFunctionNotFound(name: name)
        }
        return shader
    }
}
