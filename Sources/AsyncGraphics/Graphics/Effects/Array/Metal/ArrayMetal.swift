//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import CoreGraphics

extension Graphic {
    
    public enum ArrayMetalError: LocalizedError {
        
        case metalFileNotFound
        
        public var errorDescription: String? {
            switch self {
            case .metalFileNotFound:
                return "AsyncGraphics - Graphic - Metal - Metal File Not Found"
            }
        }
    }
    
    /// Metal Shader Code
    ///
    /// Sample the first texture color.
    /// ```
    /// float4 color = textures.sample(sampler, uv, 0);
    /// ```
    ///
    /// Get the resolution of the input textures.
    /// ```
    /// uint width = textures.get_width();
    /// uint height = textures.get_height();
    /// ```
    ///
    /// Get the texture count.
    /// ```
    /// uint count = textures.get_array_size();
    /// ```
    ///
    /// Return a `float4` color.
    /// ```
    /// return color;
    /// ```
    ///
    /// Available variables are:  `sampler`, `textures`, `textureCount`, `u`, `v`, `uv`.
    public static func metal(with graphics: [Graphic], code: String) async throws -> Graphic {
        
        guard let metalBaseURL = Bundle.module.url(forResource: "ArrayMetal.metal", withExtension: "txt") else {
            throw ArrayMetalError.metalFileNotFound
        }
        
        let metalBaseCode = try String(contentsOf: metalBaseURL)
        
        let metalCode = metalBaseCode
            .replacingOccurrences(of: "/*<code>*/", with: code)
            .replacingOccurrences(of: "return 0;", with: "")
        
        return try await Renderer.render(
            name: "Metal",
            shader: .code(metalCode, name: "arrayMetal"),
            graphics: graphics,
            options: Renderer.Options(isArray: true)
        )
    }
}

extension Array where Element == Graphic {
    
    public func metal(code: String) async throws -> Graphic {
        
        try await Graphic.metal(with: self, code: code)
    }
}
