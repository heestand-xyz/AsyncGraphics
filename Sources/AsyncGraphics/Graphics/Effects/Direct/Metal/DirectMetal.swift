//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import CoreGraphics

extension Graphic {
    
    public enum DirectMetalError: LocalizedError {
        
        case metalFileNotFound
        
        public var errorDescription: String? {
            switch self {
            case .metalFileNotFound:
                return "AsyncGraphics - Graphic - Metal - Metal File Not Found"
            }
        }
    }
    
    /// Metal Shader Code with one input
    ///
    /// Get the resolution of the input texture.
    /// ```
    /// uint width = texture.get_width();
    /// uint height = texture.get_height();
    /// ```
    ///
    /// Return a `float4` color.
    /// ```
    /// return color * 2.0;
    /// ```
    ///
    /// Available variables are:  `sampler`, `texture`, `u`, `v`, `uv`, `color`.
    public func metal(code: String,
                      options: EffectOptions = []) async throws -> Graphic {
        
        guard let metalBaseURL = Bundle.module.url(forResource: "DirectMetal.metal", withExtension: "txt") else {
            throw DirectMetalError.metalFileNotFound
        }
        
        let metalBaseCode = try String(contentsOf: metalBaseURL)
        
        let metalCode = metalBaseCode
            .replacingOccurrences(of: "/*<code>*/", with: code)
            .replacingOccurrences(of: "return 0;", with: "")
        
        return try await Renderer.render(
            name: "Metal",
            shader: .code(metalCode, name: "directMetal"),
            graphics: [self],
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
