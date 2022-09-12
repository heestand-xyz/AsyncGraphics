//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import CoreGraphics

extension Renderer {
    
    struct Vertex {
        
        let x, y: CGFloat
        let s, t: CGFloat
        
        var buffer: [Float] {
            [x, y, s, t].map(Float.init)
        }
    }
    
    enum Vertices {
        
        case indirect(count: Int, type: MTLPrimitiveType)
        case direct([Vertex], type: MTLPrimitiveType)
        
        var type: MTLPrimitiveType {
            switch self {
            case .indirect(_, let type):
                return type
            case .direct(_, let type):
                return type
            }
        }
        
        var count: Int {
            switch self {
            case .indirect(let count, _):
                return count
            case .direct(let vertices, _):
                return vertices.count
            }
        }
    }

    static func vertexQuadBuffer() throws -> MTLBuffer {
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 1.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 1.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 0.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 0.0)
        let vertices: [Vertex] = [a, b, c, b, c, d]
        return try buffer(vertices: vertices)
    }
    
    static func buffer(vertices: [Vertex]) throws -> MTLBuffer {
        precondition(!vertices.isEmpty)
        let vertexBuffer: [Float] = vertices.flatMap(\.buffer)
        let dataSize = vertexBuffer.count * MemoryLayout.size(ofValue: vertexBuffer[0])
        guard let buffer = metalDevice.makeBuffer(bytes: vertexBuffer, length: dataSize, options: []) else {
            throw RendererError.failedToMakeVertexQuadBuffer
        }
        return buffer
    }
}
