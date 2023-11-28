//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import Spatial

extension Graphic3D {
    
    public enum SolidMetal3DError: LocalizedError {
        
        case metalFileNotFound
        
        public var errorDescription: String? {
            switch self {
            case .metalFileNotFound:
                return "AsyncGraphics - Graphic3D - Metal - Metal File Not Found"
            }
        }
    }
    
    /// Metal Shader Code
    ///
    /// Return a `float4` color.
    /// ```
    /// return float4(u, v, w, 1.0);
    /// ```
    ///
    /// Available variables are:  `u`, `v`, `w`, `uvw`, `width`, `height`, `depth`.
    public static func metal(code: String,
                             resolution: Size3D,
                             options: ContentOptions = []) async throws -> Graphic3D {
        
        guard let metalBaseURL = Bundle.module.url(forResource: "SolidMetal3D.metal", withExtension: "txt") else {
            throw SolidMetal3DError.metalFileNotFound
        }
        
        let metalBaseCode = try String(contentsOf: metalBaseURL)
        
        let metalCode = metalBaseCode
            .replacingOccurrences(of: "/*<code>*/", with: code)
            .replacingOccurrences(of: "return 0;", with: "")
        
        return try await Renderer.render(
            name: "Metal 3D",
            shader: .code(metalCode, name: "solidMetal3d"),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func uvw(resolution: Size3D,
                           options: ContentOptions = []) async throws -> Graphic3D {
        
        try await metal(code: "return float4(uvw, 1.0);",
                        resolution: resolution,
                        options: options)
    }
}
