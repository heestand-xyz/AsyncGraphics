//
//  Created by Anton Heestand on 2022-09-12.
//

import Foundation

extension Renderer {
    
    enum RendererError: LocalizedError {
        
        case metalLibraryNotFound
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
        case noTargetTextureFound
        
        var errorDescription: String? {
            switch self {
            case .metalLibraryNotFound:
                return "AsyncGraphics - Renderer - Metal Library Not Found"
            case .badMetadata:
                return "AsyncGraphics - Renderer - Bad Metadata"
            case .failedToMakeVertexQuadBuffer:
                return "AsyncGraphics - Renderer - Failed to Make Vertex Quad Buffer"
            case .shaderFunctionNotFound(let name):
                return "AsyncGraphics - Renderer - Shader Function Not Found (\"\(name)\")"
            case .failedToMakeCommandBuffer:
                return "AsyncGraphics - Renderer - Failed to Make Command Buffer"
            case .failedToMakeCommandEncoder:
                return "AsyncGraphics - Renderer - Failed to Make Command Encoder"
            case .failedToMakeCommandQueue:
                return "AsyncGraphics - Renderer - Failed to Make Command Queue"
            case .failedToMakeSampler:
                return "AsyncGraphics - Renderer - Failed to Make Sampler"
            case .failedToMakeUniformBuffer:
                return "AsyncGraphics - Renderer - Failed to Make Uniform Buffer"
            case .failedToMakeArrayUniformBuffer:
                return "AsyncGraphics - Renderer - Failed to Make Array Uniform Buffer"
            case .failedToMakeVertexUniformBuffer:
                return "AsyncGraphics - Renderer - Failed to Make Vertex Uniform Buffer"
            case .failedToMakeComputeCommandEncoder:
                return "AsyncGraphics - Renderer - Failed to Make Compute Command Encoder"
            case .graphic3dIsCurrentlyOnlySupportedOnMacOS:
                return "AsyncGraphics - Renderer - Graphic3D is Currently Only Supported on macOS"
            case .noTargetTextureFound:
                return "AsyncGraphics - Renderer - No Target Texture Found"
            }
        }
    }
}
