//
//  File.swift
//  
//
//  Created by Anton on 2024-03-19.
//

import Foundation
import Spatial

extension Graphic3D {
    
    public struct Tile: Hashable, Sendable {
        
        public struct Point: Hashable, Sendable {
            public var x: Int
            public var y: Int
            public var z: Int
            public init(x: Int, y: Int, z: Int) {
                self.x = x
                self.y = y
                self.z = z
            }
            public static let zero = Point(x: 0, y: 0, z: 0)
        }
        
        public struct Size: Hashable, Sendable {
            public var width: Int
            public var height: Int
            public var depth: Int
            public init(width: Int, height: Int, depth: Int) {
                self.width = width
                self.height = height
                self.depth = depth
            }
            public static let zero = Size(width: 0, height: 0, depth: 0)
            public static let one = Size(width: 1, height: 1, depth: 1)
        }
        
        public static let one = Tile(origin: .zero, count: .one, padding: 0.0)
        
        public var origin: Point
        public var count: Size
        public var padding: CGFloat
        
        var uvOrigin: VectorUniform {
            VectorUniform(x: (Float(origin.x) - Float(padding)) / Float(count.width),
                          y: (Float(origin.y) - Float(padding)) / Float(count.height),
                          z: (Float(origin.z) - Float(padding)) / Float(count.depth))
        }
        
        var uvSize: VectorUniform {
            VectorUniform(x: Float(1.0 + padding * 2) / Float(count.width),
                          y: Float(1.0 + padding * 2) / Float(count.height),
                          z: Float(1.0 + padding * 2) / Float(count.depth))
        }
        
        public init(origin: Point, count: Size, padding: CGFloat = 0.0) {
            self.origin = origin
            self.count = count
            self.padding = padding
        }
        
        func resolution(at resolution: Size3D) -> Size3D {
            Size3D(width: (resolution.width / CGFloat(count.width)) * (1.0 + padding * 2),
                   height: (resolution.height / CGFloat(count.height)) * (1.0 + padding * 2),
                   depth: (resolution.depth / CGFloat(count.depth)) * (1.0 + padding * 2))
        }
    }
}

