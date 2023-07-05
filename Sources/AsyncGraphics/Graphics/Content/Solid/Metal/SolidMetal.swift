//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import CoreGraphics

extension Graphic {
    
    public enum SolidMetalError: LocalizedError {
        
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
    /// Get the resolution of the input texture.
    /// ```
    /// float width = uniforms.resolution.x;
    /// float height = uniforms.resolution.y;
    /// ```
    ///
    /// Return a `float4` color.
    /// ```
    /// return float4(u, v, 1.0, 1.0);
    /// ```
    ///
    /// Available variables are:  `u`, `v`, `uv`.
    public static func metal(code: String,
                             resolution: CGSize,
                             options: ContentOptions = []) async throws -> Graphic {
        
        guard let metalBaseURL = Bundle.module.url(forResource: "SolidMetal.metal", withExtension: "txt") else {
            throw SolidMetalError.metalFileNotFound
        }
        
        let metalBaseCode = try String(contentsOf: metalBaseURL)
                
        let metalCode = metalBaseCode
            .replacingOccurrences(of: "/*<code>*/", with: code)
            .replacingOccurrences(of: "return 0;", with: "")
        
        return try await Renderer.render(
            name: "Metal",
            shader: .code(metalCode, name: "solidMetal"),
            uniforms: resolution.uniform,
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    /// A convenience graphic for creating a UV image
    ///
    /// A UV image is tow gradients added together:
    ///
    /// U: Black to Red Horizontally
    ///
    /// V: Black to Green Vertically
    public static func uv(resolution: CGSize,
                          options: ContentOptions = []) async throws -> Graphic {
        
        try await metal(code: "return float4(uv, 0.0, 1.0);",
                        resolution: resolution,
                        options: options)
    }
}
