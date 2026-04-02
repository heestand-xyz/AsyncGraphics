//
//  GridWarp.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-04-02.
//

import CoreGraphics

extension Graphic {
    
    /// A grid with fractional vertices.
    public struct Grid: Sendable {
        /// Fractional location.
        public struct Vertex: Sendable {
            public var x: CGFloat
            public var y: CGFloat
            public var u: CGFloat
            public var v: CGFloat
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
        public var flatVertices: [[Vertex]] {
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
                    let centerVetex = Vertex(
                        x: (vertex.x + rightVertex.x + bottomVertex.x + bottomRightVertex.x) / 4,
                        y: (vertex.y + rightVertex.y + bottomVertex.y + bottomRightVertex.y) / 4,
                        u: (vertex.u + rightVertex.u + bottomVertex.u + bottomRightVertex.u) / 4,
                        v: (vertex.v + rightVertex.v + bottomVertex.v + bottomRightVertex.v) / 4,
                    )
                    flatVertices.append([
                        centerVetex,
                        bottomVertex,
                        vertex,
                    ])
                    flatVertices.append([
                        centerVetex,
                        vertex,
                        rightVertex,
                    ])
                    flatVertices.append([
                        centerVetex,
                        rightVertex,
                        bottomRightVertex,
                    ])
                    flatVertices.append([
                        centerVetex,
                        bottomRightVertex,
                        bottomVertex,
                    ])
                }
            }
            return flatVertices
        }
    }
    
    /// Warp graphic with a grid.
    public func warp(grid: Grid) async throws -> Graphic {
        try await Renderer.render(
            name: "Grid Warp",
            shader: .passthrough,
            graphics: [self],
            vertices: .direct(
                grid.flatVertices.flatMap({ $0 }).map(\.rendererVertex),
                type: .triangle
            )
        )
    }
}
