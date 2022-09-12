//
//  Created by Anton Heestand on 2022-09-12.
//

import Foundation

extension Renderer {
    
    enum RendererError: LocalizedError {
        
        case badMetadata
        case failedToMakeVertexQuadBuffer
        case shaderFunctionNotFound(name: String)
        case failedToMakeCommandBuffer
        case failedToMakeCommandEncoder
        case failedToMakeCommandQueue
        case failedToMakeSampler
        case failedToMakeUniformBuffer
        case failedToMakeArrayUniformBuffer
        case failedToMakeVertexUniformBuffer
        case failedToMakeComputeCommandEncoder
        case graphic3dIsCurrentlyOnlySupportedOnMacOS
        
        var errorDescription: String? {
            switch self {
            case .badMetadata:
                return "Async Graphics - Renderer - Bad Metadata"
            case .failedToMakeVertexQuadBuffer:
                return "Async Graphics - Renderer - Failed to Make Vertex Quad Buffer"
            case .shaderFunctionNotFound(let name):
                return "Async Graphics - Renderer - Shader Function Not Found (\"\(name)\")"
            case .failedToMakeCommandBuffer:
                return "Async Graphics - Renderer - Failed to Make Command Buffer"
            case .failedToMakeCommandEncoder:
                return "Async Graphics - Renderer - Failed to Make Command Encoder"
            case .failedToMakeCommandQueue:
                return "Async Graphics - Renderer - Failed to Make Command Queue"
            case .failedToMakeSampler:
                return "Async Graphics - Renderer - Failed to Make Sampler"
            case .failedToMakeUniformBuffer:
                return "Async Graphics - Renderer - Failed to Make Uniform Buffer"
            case .failedToMakeArrayUniformBuffer:
                return "Async Graphics - Renderer - Failed to Make Array Uniform Buffer"
            case .failedToMakeVertexUniformBuffer:
                return "Async Graphics - Renderer - Failed to Make Vertex Uniform Buffer"
            case .failedToMakeComputeCommandEncoder:
                return "Async Graphics - Renderer - Failed to Make Compute Command Encoder"
            case .graphic3dIsCurrentlyOnlySupportedOnMacOS:
                return "Async Graphics - Renderer - Graphic3D is Currently Only Supported on macOS"
            }
        }
    }
}
