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
        let floats: [Float] = vertices.flatMap(\.buffer)
        return try buffer(floats: floats)
    }
    
    static func buffer(count: Int) throws -> MTLBuffer {
        precondition(count > 0)
        let floats: [Float] = Array(repeating: 0.0, count: 4 * count)
        return try buffer(floats: floats)
    }
    
    private static func buffer(floats: [Float]) throws -> MTLBuffer {
        precondition(!floats.isEmpty)
        let dataSize = floats.count * MemoryLayout.size(ofValue: floats[0])
        guard let buffer = metalDevice.makeBuffer(bytes: floats, length: dataSize, options: []) else {
            throw RendererError.failedToMakeVertexQuadBuffer
        }
        return buffer
    }
}
