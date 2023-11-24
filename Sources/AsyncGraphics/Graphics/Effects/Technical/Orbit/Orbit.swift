//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic3D {
    
    public func orbit(
        backgroundColor: PixelColor = .clear,
        rotationX: Angle = .zero,
        rotationY: Angle = .zero,
        resolution: CGSize
    ) async throws -> Graphic {
       
        let vertices: [Renderer.Vertex3D] = Self.orbitVertices(depthCount: depth)
        
        return try await Renderer.render(
            name: "Orbit",
            shader: .camera("orbit"),
            graphics: [self],
            vertices: .direct(vertices, type: .triangle),
            camera: Renderer.Camera(
                fieldOfView: .degrees(60),
                position: SIMD3<Double>(0.0, 0.0, -2.5)
            ),
            rotationX: rotationX,
            rotationY: rotationY,
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
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
            let z = fraction * 2.0 - 1.0
            
            vertices.append(contentsOf: [
                Renderer.Vertex3D(x: -1.0, y: -1.0, z: z, u: 0.0, v: 0.0, w: fraction),
                Renderer.Vertex3D(x: 1.0, y: -1.0, z: z, u: 1.0, v: 0.0, w: fraction),
                Renderer.Vertex3D(x: -1.0, y: 1.0, z: z, u: 0.0, v: 1.0, w: fraction),
            ])
            
            vertices.append(contentsOf: [
                Renderer.Vertex3D(x: -1.0, y: 1.0, z: z, u: 0.0, v: 1.0, w: fraction),
                Renderer.Vertex3D(x: 1.0, y: -1.0, z: z, u: 1.0, v: 0.0, w: fraction),
                Renderer.Vertex3D(x: 1.0, y: 1.0, z: z, u: 1.0, v: 1.0, w: fraction),
            ])
        }
        
        return vertices
    }
}
