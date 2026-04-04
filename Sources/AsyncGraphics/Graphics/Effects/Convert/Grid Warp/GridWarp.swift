//
//  GridWarp.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-04-02.
//

import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    /// A grid with fractional vertices.
    public struct Grid: Sendable {
        /// Fractional location.
        public struct Vertex: Sendable {
            public var x: CGFloat
            public var y: CGFloat
            public var u: CGFloat
            public var v: CGFloat
            public var point: CGPoint {
                get {
                    CGPoint(x: x, y: y)
                }
                set {
                    x = newValue.x
                    y = newValue.y
                }
            }
            public var uv: CGPoint {
                get {
                    CGPoint(x: u, y: v)
                }
                set {
                    u = newValue.x
                    v = newValue.y
                }
            }
            var rendererVertex: Renderer.Vertex {
                Renderer.Vertex(x: x * 2.0 - 1.0, y: (1.0 - y) * 2.0 - 1.0, u: u, v: v)
            }
            public init(uv: CGPoint) {
                self.init(at: uv, uv: uv)
            }
            public init(at point: CGPoint, uv: CGPoint) {
                x = point.x
                y = point.y
                u = uv.x
                v = uv.y
            }
            init(x: CGFloat, y: CGFloat, u: CGFloat, v: CGFloat) {
                self.x = x
                self.y = y
                self.u = u
                self.v = v
            }
        }
        /// A list of rows of vertices.
        public var vertices: [[Vertex]] = []
        /// Initialize with a list of rows of vertices.
        public init(vertices: [[Vertex]]) {
            self.vertices = vertices
        }
        public init(xCount: Int, yCount: Int) {
            for y in 0..<yCount {
                let yFraction = CGFloat(y) / CGFloat(yCount - 1)
                var vertexRow: [Vertex] = []
                for x in 0..<xCount {
                    let xFraction = CGFloat(x) / CGFloat(xCount - 1)
                    let uv = CGPoint(x: xFraction, y: yFraction)
                    let vertex = Vertex(uv: uv)
                    vertexRow.append(vertex)
                }
                vertices.append(vertexRow)
            }
        }
        /// Vertices for polygons. Grouped by 3 vertices per polygon.
        public func flatVertices(diagonalIntersection: Bool) -> [[Vertex]] {
            var flatVertices: [[Vertex]] = []
            for (y, vertexRow) in vertices.enumerated() {
                guard y < vertices.count - 1 else { continue }
                let nextVertexRow: [Vertex] = vertices[y + 1]
                for (x, vertex) in vertexRow.enumerated() {
                    guard x < vertexRow.count - 1 else { continue }
                    let rightVertex = vertexRow[x + 1]
                    guard nextVertexRow.indices.contains(x) else { continue }
                    let bottomVertex = nextVertexRow[x]
                    guard nextVertexRow.indices.contains(x + 1) else { continue }
                    let bottomRightVertex = nextVertexRow[x + 1]
                    let pointCenter: CGPoint = if diagonalIntersection {
                        intersection(
                            line1a: vertex.point,
                            line1b: bottomRightVertex.point,
                            line2a: rightVertex.point,
                            line2b: bottomVertex.point
                        )
                    } else {
                        average(
                            vertex.point,
                            rightVertex.point,
                            bottomVertex.point,
                            bottomRightVertex.point,
                        )
                    }
                    let uvCenter: CGPoint = average(
                        vertex.uv,
                        rightVertex.uv,
                        bottomVertex.uv,
                        bottomRightVertex.uv,
                    )
                    let centerVertex = Vertex(at: pointCenter, uv: uvCenter)
                    flatVertices.append([
                        centerVertex,
                        bottomVertex,
                        vertex,
                    ])
                    flatVertices.append([
                        centerVertex,
                        vertex,
                        rightVertex,
                    ])
                    flatVertices.append([
                        centerVertex,
                        rightVertex,
                        bottomRightVertex,
                    ])
                    flatVertices.append([
                        centerVertex,
                        bottomRightVertex,
                        bottomVertex,
                    ])
                }
            }
            return flatVertices
        }
        
        private func average(
            _ p1: CGPoint, _ p2: CGPoint,
            _ p3: CGPoint, _ p4: CGPoint
        ) -> CGPoint {
            (p1 + p2 + p3 + p4) / 4
        }
        
        private func intersection(
            line1a p1: CGPoint, line1b p2: CGPoint,
            line2a p3: CGPoint, line2b p4: CGPoint
        ) -> CGPoint {

            let a1 = p2.y - p1.y
            let b1 = p1.x - p2.x
            let c1 = a1 * p1.x + b1 * p1.y

            let a2 = p4.y - p3.y
            let b2 = p3.x - p4.x
            let c2 = a2 * p3.x + b2 * p3.y

            let det = a1 * b2 - a2 * b1
            guard abs(det) > .ulpOfOne else {
                return average(p1, p2, p3, p4)
            }

            return CGPoint(
                x: (b2 * c1 - b1 * c2) / det,
                y: (a1 * c2 - a2 * c1) / det
            )
        }
    }
    
    /// Warp graphic with a grid.
    ///
    /// Perspective uses diagonal intersection instead of averaging to determine each quad center.
    public func warp(grid: Grid, perspective: Bool = false) async throws -> Graphic {
        try await Renderer.render(
            name: "Grid Warp",
            shader: .passthrough,
            graphics: [self],
            vertices: .direct(
                grid.flatVertices(
                    diagonalIntersection: perspective
                ).flatMap({ $0 }).map(\.rendererVertex),
                type: .triangle
            )
        )
    }
}
