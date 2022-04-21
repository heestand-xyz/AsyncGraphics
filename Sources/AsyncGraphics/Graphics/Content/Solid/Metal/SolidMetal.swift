//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import CoreGraphics

extension Graphic {
    
    public enum SolidMetalError: LocalizedError {
        
        case metalFileNotFound
//        case spaceInMetalUniformName
        
        public var errorDescription: String? {
            switch self {
            case .metalFileNotFound:
                return "AsyncGraphics - Graphic - Metal - Metal File Not Found"
//            case .spaceInMetalUniformName:
//                return "AsyncGraphics - Graphic - Metal - Space in Metal Uniform Name"
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
//                             uniforms: [String: MetalUniform] = [:],
                             at graphicSize: CGSize) async throws -> Graphic {
        
        guard let metalBaseURL = Bundle.module.url(forResource: "SolidMetal.metal", withExtension: "txt") else {
            throw SolidMetalError.metalFileNotFound
        }
        
        let metalBaseCode = try String(contentsOf: metalBaseURL)
        
//        var uniformsCode: String = ""
//        for (index, (key, uniform)) in uniforms.enumerated() {
//            guard !key.contains(" ") else {
//                throw MetalError.spaceInMetalUniformName
//            }
//            uniformsCode += "\(uniform.raw.metalTypeName) \(key);"
//            if index > 0 {
//                uniformsCode += "\n    "
//            }
//        }
        
        let metalCode = metalBaseCode
//            .replacingOccurrences(of: "/*<uniforms>*/", with: uniformsCode)
            .replacingOccurrences(of: "/*<code>*/", with: code)
            .replacingOccurrences(of: "return 0;", with: "")
        
//        var rawUniforms: [RawMetalUniform] = [uniforms.map(\.value.raw)
//        rawUniforms.append(SIMD2<Float>(Float(graphicSize.resolution.width),
        
        return try await Renderer.render(
            name: "Metal",
            shader: .code(metalCode, name: "solidMetal"),
            uniforms: graphicSize.resolution.uniform,
            metadata: Renderer.Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
    
    public static func uv(at graphicSize: CGSize) async throws -> Graphic {
        
        try await metal(code: "return float4(uv, 0.0, 1.0);", at: graphicSize)
    }
}
