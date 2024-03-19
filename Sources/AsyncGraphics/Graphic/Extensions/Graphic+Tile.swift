//
//  File.swift
//  
//
//  Created by Anton on 2024-03-19.
//

import Foundation

extension Graphic {
    
    public struct Tile: Hashable {
        
        public struct Point: Hashable {
            public var x: Int
            public var y: Int
            public init(x: Int, y: Int) {
                self.x = x
                self.y = y
            }
            public static let zero = Point(x: 0, y: 0)
        }
        
        public struct Size: Hashable {
            public var width: Int
            public var height: Int
            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
            public static let zero = Size(width: 0, height: 0)
            public static let one = Size(width: 1, height: 1)
        }
        
        public static let one = Tile(origin: .zero, count: .one, padding: 0.0)
        
        public var origin: Point
        public var count: Size
        public var padding: CGFloat
        
        var uvOrigin: PointUniform {
            PointUniform(x: (Float(origin.x) - Float(padding)) / Float(count.width),
                         y: (Float(origin.y) - Float(padding)) / Float(count.height))
        }
        
        var uvSize: SizeUniform {
            SizeUniform(width: Float(1.0 + padding * 2) / Float(count.width),
                        height: Float(1.0 + padding * 2) / Float(count.height))
        }
        
        public init(origin: Point, count: Size, padding: CGFloat = 0.0) {
            self.origin = origin
            self.count = count
            self.padding = padding
        }
        
        func resolution(at resolution: CGSize) -> CGSize {
            CGSize(width: (resolution.width / CGFloat(count.width)) * (1.0 + padding * 2),
                   height: (resolution.height / CGFloat(count.height)) * (1.0 + padding * 2))
        }
    }
}

