////
////  Created by Anton Heestand on 2022-04-20.
////
//
//import Spatial
//
//public protocol RawMetalUniform {
//    var metalTypeName: String { get }
//}
//
//extension Bool: RawMetalUniform {
//    public var metalTypeName: String { "bool" }
//}
//
//extension Int32: RawMetalUniform {
//    public var metalTypeName: String { "int" }
//}
//
//extension UInt32: RawMetalUniform {
//    public var metalTypeName: String { "uint" }
//}
//
//extension Float: RawMetalUniform {
//    public var metalTypeName: String { "float" }
//}
//
//extension SIMD2: RawMetalUniform where Scalar == Float {
//    public var metalTypeName: String { "packed_float2" }
//}
//
//extension SIMD3: RawMetalUniform where Scalar == Float {
//    public var metalTypeName: String { "packed_float3" }
//}
//
//extension SIMD4: RawMetalUniform where Scalar == Float {
//    public var metalTypeName: String { "packed_float4" }
//}
