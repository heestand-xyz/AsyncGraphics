//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import CoreGraphics

protocol Vertexable {
    var buffer: [Float] { get }
}

extension Renderer {
    
    struct Vertex: Vertexable {
        
        let x, y: CGFloat
        let u, v: CGFloat
        
        var buffer: [Float] {
            [x, y, u, v].map(Float.init)
        }
    }
    
    struct Vertex3D: Vertexable {
        
        let x, y, z: CGFloat
        let u, v, w: CGFloat
        
        var buffer: [Float] {
            [x, y, z, u, v, w].map(Float.init)
        }
    }
    
    enum Vertices {
        
        case indirect(count: Int, type: MTLPrimitiveType)
        case direct([any Vertexable], type: MTLPrimitiveType)
        
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
        let a = Vertex(x: -1.0, y: -1.0, u: 0.0, v: 1.0)
        let b = Vertex(x: 1.0, y: -1.0, u: 1.0, v: 1.0)
        let c = Vertex(x: -1.0, y: 1.0, u: 0.0, v: 0.0)
        let d = Vertex(x: 1.0, y: 1.0, u: 1.0, v: 0.0)
        let vertices: [Vertex] = [a, b, c, b, c, d]
        return try buffer(vertices: vertices)
    }
    
    static func buffer(vertices: [any Vertexable]) throws -> MTLBuffer {
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
