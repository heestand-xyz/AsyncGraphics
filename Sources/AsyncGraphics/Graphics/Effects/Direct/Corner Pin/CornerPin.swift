//
//  Created by Anton Heestand on 2022-09-12.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    public func cornerPinned(
        topLeft: CGPoint? = nil,
        topRight: CGPoint? = nil,
        bottomLeft: CGPoint? = nil,
        bottomRight: CGPoint? = nil,
        perspective: Bool = true,
        subdivisions: Int = 32,
        backgroundColor: PixelColor = .clear
    ) async throws -> Graphic {
       
        let relativeTopLeft: CGPoint = (topLeft ?? .zero) / resolution
        let relativeTopRight: CGPoint = (topRight ?? CGPoint(x: resolution.width, y: 0.0)) / resolution
        let relativeBottomLeft: CGPoint = (bottomLeft ?? CGPoint(x: 0.0, y: resolution.height)) / resolution
        let relativeBottomRight: CGPoint = (bottomRight ?? resolution.asPoint) / resolution
        
        let vertices: [Renderer.Vertex] = Self.mapVertices(
            Self.cornerPinVertices(
                topLeft: Self.uvFlipY(relativeTopLeft),
                topRight: Self.uvFlipY(relativeTopRight),
                bottomLeft: Self.uvFlipY(relativeBottomLeft),
                bottomRight: Self.uvFlipY(relativeBottomRight),
                perspective: perspective,
                subdivisions: subdivisions
            ),
            subdivisions: subdivisions
        )
        
        return try await Renderer.render(
            name: "Corner Pin",
            shader: .passthrough,
            graphics: [self],
            vertices: .direct(vertices, type: .triangle),
            options: Renderer.Options(
                clearColor: backgroundColor
            )
        )
    }
}

extension Graphic {
    
    private static func uvFlipY(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x, y: 1.0 - point.y)
    }
    
    private static func cornerPinVertices(
        topLeft: CGPoint,
        topRight: CGPoint,
        bottomLeft: CGPoint,
        bottomRight: CGPoint,
        perspective: Bool,
        subdivisions: Int
    ) -> [[Renderer.Vertex]] {
        
        let cx = [bottomLeft.x, bottomRight.x, topRight.x, topLeft.x]
        let cy = [bottomLeft.y, bottomRight.y, topRight.y, topLeft.y]
        
        let sX = cx[0]-cx[1]+cx[2]-cx[3]
        let sY = cy[0]-cy[1]+cy[2]-cy[3]
        
        let dX1 = cx[1]-cx[2]
        let dX2 = cx[3]-cx[2]
        let dY1 = cy[1]-cy[2]
        let dY2 = cy[3]-cy[2]
        
        let a: CGFloat
        let b: CGFloat
        let c: CGFloat
        let d: CGFloat
        let e: CGFloat
        let f: CGFloat
        let g: CGFloat
        let h: CGFloat
        
        if sX == 0 && sY == 0 {
            a = cx[1] - cx[0]
            b = cx[2] - cx[1]
            c = cx[0]
            d = cy[1] - cy[0]
            e = cy[2] - cy[1]
            f = cy[0]
            g = 0
            h = 0
        } else {
            g = (sX*dY2-dX2*sY)/(dX1*dY2-dX2*dY1)
            h = (dX1*sY-sX*dY1)/(dX1*dY2-dX2*dY1)
            a = cx[1] - cx[0] + g * cx[1]
            b = cx[3] - cx[0] + h * cx[3]
            c = cx[0]
            d = cy[1] - cy[0] + g * cy[1]
            e = cy[3] - cy[0] + h * cy[3]
            f = cy[0]
            
        }
        
        var verts: [[Renderer.Vertex]] = []
        
        for x in 0...subdivisions {
            var col_verts: [Renderer.Vertex] = []
            for y in 0...subdivisions {
                let u = CGFloat(x) / CGFloat(subdivisions)
                let v = CGFloat(y) / CGFloat(subdivisions)
                let pos: CGPoint
                if perspective {
                    pos = CGPoint(x: (a*u + b*v + c) / (g*u+h*v+1), y: (d*u + e*v + f) / (g*u+h*v+1))
                } else {
                    let bottom = add(scale(bottomLeft, by: 1.0 - u), scale(bottomRight, by: u))
                    let top = add(scale(topLeft, by: 1.0 - u), scale(topRight, by: u))
                    pos = add(scale(bottom, by: 1.0 - v), scale(top, by: v))
                }
                let vert = Renderer.Vertex(x: CGFloat(pos.x * 2 - 1), y: CGFloat(pos.y * 2 - 1), s: CGFloat(u), t: CGFloat(1.0 - v))
                col_verts.append(vert)
            }
            verts.append(col_verts)
        }
        
        return verts
        
    }
    
    private static func scale(_ point: CGPoint, by scale: CGFloat) -> CGPoint {
        CGPoint(x: point.x * scale, y: point.y * scale)
    }
    
    private static func add(_ pointA: CGPoint, _ pointB: CGPoint) -> CGPoint {
        CGPoint(x: pointA.x + pointB.x, y: pointA.y + pointB.y)
    }
    
    private static func mapVertices(_ vertices: [[Renderer.Vertex]], subdivisions: Int) -> [Renderer.Vertex] {
        var verticesMap: [Renderer.Vertex] = []
        for x in 0..<subdivisions {
            for y in 0..<subdivisions {
                let vertexBottomLeft = vertices[x][y]
                let vertexTopLeft = vertices[x][y + 1]
                let vertexBottomRight = vertices[x + 1][y]
                let vertexTopRight = vertices[x + 1][y + 1]
                verticesMap.append(vertexTopLeft)
                verticesMap.append(vertexTopRight)
                verticesMap.append(vertexBottomLeft)
                verticesMap.append(vertexBottomRight)
                verticesMap.append(vertexBottomLeft)
                verticesMap.append(vertexTopRight)
            }
        }
        return verticesMap
    }
}
