import SwiftUI
import simd

extension Renderer {
    
    struct Camera {
        let fieldOfView: Angle
        let position: SIMD3<Double>
//        let rotation: SIMD3<Double>
        let near: Double = 0.1
        let far: Double = 10.0
    }
    
    static func perspective(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let ys = 1 / tanf(fovy * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
        return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
                                             vector_float4( 0, ys, 0,   0),
                                             vector_float4( 0,  0, zs, -1),
                                             vector_float4( 0,  0, zs * nearZ, 0)))
    }
    
    static func radians(degrees: Float) -> Float {
        (degrees / 180) * .pi
    }
    
    static func translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
        matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                      vector_float4(0, 1, 0, 0),
                                      vector_float4(0, 0, 1, 0),
                                      vector_float4(translationX, translationY, translationZ, 1)))
    }
    
    static func rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
        let unitAxis = normalize(axis)
        let ct = cosf(radians)
        let st = sinf(radians)
        let ci = 1 - ct
        let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
        return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                             vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                             vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                             vector_float4(                  0,                   0,                   0, 1)))
    }

}
