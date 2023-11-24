//
//  Created by Anton Heestand on 2022-09-12.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic3D {
    
    public func orbit(
        backgroundColor: PixelColor = .clear
    ) async throws -> Graphic {
       
        let vertices: [Renderer.Vertex3D] = Self.orbitVertices(depthCount: depth)
        
        return try await Renderer.render(
            name: "Orbit",
            shader: .custom(
                fragment: "orbit",
                vertex: "vertexCamera"
            ),
            graphics: [self],
            vertices: .direct(vertices, type: .triangle),
            options: Renderer.Options(
                clearColor: backgroundColor,
                depth: true
            )
        )
    }
}

extension Graphic3D {
    
    private static func orbitVertices(
        depthCount: Int
    ) -> [Renderer.Vertex3D] {
        
        var vertices: [Renderer.Vertex3D] = []
        
        for index in 0..<depthCount {
            
            let fraction = CGFloat(index) / CGFloat(depthCount - 1)
            
            vertices.append(contentsOf: [
                Renderer.Vertex3D(x: 0.0, y: 0.0, z: fraction, u: 0.0, v: 0.0, w: fraction),
                Renderer.Vertex3D(x: 1.0, y: 0.0, z: fraction, u: 1.0, v: 0.0, w: fraction),
                Renderer.Vertex3D(x: 0.0, y: 1.0, z: fraction, u: 0.0, v: 1.0, w: fraction),
            ])
            
            vertices.append(contentsOf: [
                Renderer.Vertex3D(x: 0.0, y: 1.0, z: fraction, u: 0.0, v: 1.0, w: fraction),
                Renderer.Vertex3D(x: 1.0, y: 0.0, z: fraction, u: 1.0, v: 0.0, w: fraction),
                Renderer.Vertex3D(x: 1.0, y: 1.0, z: fraction, u: 1.0, v: 1.0, w: fraction),
            ])
        }
        
        return vertices
    }
}
