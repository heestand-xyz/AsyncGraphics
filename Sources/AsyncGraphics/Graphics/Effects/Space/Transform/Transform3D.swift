//
//  Created by Anton Heestand on 2022-04-22.
//

import Spatial
import SwiftUI

extension Graphic3D {
    
    private struct Transform3DUniforms {
        let translation: VectorUniform
        let rotation: VectorUniform
        let scale: Float
        let size: VectorUniform
    }
    
    public func translated(_ translation: Point3D,
                           options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(translation: translation, options: options)
    }
    
    public func translated(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0,
                           options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(translation: Point3D(x: x, y: y, z: z), options: options)
    }
    
    public func rotated(_ rotation: Point3D,
                        options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(rotation: rotation, options: options)
    }
    
    public func rotated(x: Angle = .zero, y: Angle = .zero, z: Angle = .zero,
                        options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(rotation: Point3D(x: Double(x.uniform), y: Double(y.uniform), z: Double(z.uniform)), options: options)
    }
    
    public func scaled(_ scale: Double,
                       options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(scale: scale, options: options)
    }
    
    public func scaled(_ scale: Point3D,
                       options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(scaleSize: scale, options: options)
    }
    
    public func scaled(x: Double = 1.0, y: Double = 1.0, z: Double = 1.0,
                       options: EffectOptions = []) async throws -> Graphic3D {
        try await transformed(scaleSize: Point3D(x: x, y: y, z: z), options: options)
    }
    
    public func transformed(
        translation: Point3D = .zero,
        rotation: Point3D = .zero,
        scale: Double = 1.0,
        scaleSize: Point3D = .one,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let relativeTranslation: Point3D = translation / Double(height)
        
        return try await Renderer.render(
            name: "Transform 3D",
            shader: .name("transform3d"),
            graphics: [self],
            uniforms: Transform3DUniforms(
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: scaleSize.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
