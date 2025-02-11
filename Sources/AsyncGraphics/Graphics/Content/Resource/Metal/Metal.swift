//
//  Created by Anton Heestand on 2022-04-20.
//

import Metal

extension Graphic {
    
    /// Raw Metal Shader Code
    public static func rawMetal(with graphics: [Graphic] = [],
                                code: String,
                                functionName: String,
                                uniformsBuffer: MTLBuffer? = nil,
                                resolution: CGSize,
                                options: ContentOptions = []) async throws -> Graphic {
        
        return try await Renderer.render(
            name: "Raw Metal",
            shader: .code(code, name: functionName),
            graphics: graphics,
            uniformsBuffer: uniformsBuffer,
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
