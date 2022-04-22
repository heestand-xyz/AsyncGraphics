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

    static func vertexQuadBuffer() throws -> MTLBuffer {
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 1.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 1.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 0.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 0.0)
        let vertices: [Vertex] = [a, b, c, b, c, d]
        return try buffer(vertices: vertices)
    }
    
//    static func vertexBuffer(vertices: [CGPoint]) throws -> MTLBuffer {
//        let vertices: [Vertex] = vertices.map { point in
//            Vertex(x: point.x, y: point.y, s: 0.0, t: 0.0)
//        }
//        return try buffer(vertices: vertices)
//    }
    
    private static func buffer(vertices: [Vertex]) throws -> MTLBuffer {
        let vertexBuffer: [Float] = vertices.flatMap(\.buffer)
        let dataSize = vertexBuffer.count * MemoryLayout.size(ofValue: vertexBuffer[0])
        guard let buffer = metalDevice.makeBuffer(bytes: vertexBuffer, length: dataSize, options: []) else {
            throw RendererError.failedToMakeVertexQuadBuffer
        }
        return buffer
    }
}
