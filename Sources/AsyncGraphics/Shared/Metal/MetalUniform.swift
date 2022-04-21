////
////  Created by Anton Heestand on 2022-04-20.
////
//
//import Foundation
//import CoreGraphics
//import simd
//import PixelColor
//
//public protocol MetalUniform {
//    var raw: RawMetalUniform { get }
//}
//
//extension Bool: MetalUniform {
//    public var raw: RawMetalUniform { self }
//}
//
//extension Int: MetalUniform {
//    public var raw: RawMetalUniform { Int32(self) }
//}
//
//extension UInt: MetalUniform {
//    public var raw: RawMetalUniform { UInt32(self) }
//}
//
//extension CGFloat: MetalUniform {
//    public var raw: RawMetalUniform { Float(self) }
//}
//
//extension Double: MetalUniform {
//    public var raw: RawMetalUniform { Float(self) }
//}
//
//extension CGPoint: MetalUniform {
//    public var raw: RawMetalUniform { SIMD2<Float>(Float(x), Float(y)) }
//}
//
//extension CGSize: MetalUniform {
//    public var raw: RawMetalUniform { SIMD2<Float>(Float(width), Float(height)) }
//}
//
//extension PixelColor: MetalUniform {
//    public var raw: RawMetalUniform { SIMD4<Float>(Float(red), Float(green), Float(blue), Float(alpha)) }
//}
