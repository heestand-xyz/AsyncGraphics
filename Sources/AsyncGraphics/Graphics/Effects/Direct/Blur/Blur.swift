//
//  Created by Anton Heestand on 2022-04-07.
//

import Metal
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI

extension Graphic {
    
    private struct BlurUniforms {
        let type: Int32
        let radius: Float
        let count: Int32
        let angle: Float
        let position: PointUniform
    }
    
    private enum BlurType: Int32 {
        case gaussian
        case box
        case angle
        case zoom
        case random
    }
    
    public func blurredBox(radius: CGFloat,
                           sampleCount: Int = 100) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Box)",
            shaderName: "blur",
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.box.rawValue,
                radius: Float(relativeRadius),
                count: Int32(sampleCount),
                angle: 0.0,
                position: CGPoint.zero.uniform
            )
        )
    }
    
    public func blurredZoom(radius: CGFloat,
                            center: CGPoint? = nil,
                            sampleCount: Int = 100) async throws -> Graphic {
        
        let center: CGPoint = center?.flipPositionY(size: size) ?? size.asPoint / 2
        let relativeCenter: CGPoint = (center - size / 2) / height
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Zoom)",
            shaderName: "blur",
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.zoom.rawValue,
                radius: Float(relativeRadius),
                count: Int32(sampleCount),
                angle: 0.0,
                position: relativeCenter.uniform
            )
        )
    }
    
    public func blurredAngle(radius: CGFloat,
                             angle: Angle,
                             sampleCount: Int = 100) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Angle)",
            shaderName: "blur",
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.angle.rawValue,
                radius: Float(relativeRadius),
                count: Int32(sampleCount),
                angle: angle.uniform,
                position: CGPoint.zero.uniform
            )
        )
    }
    
    public func blurredRandom(radius: CGFloat) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Random)",
            shaderName: "blur",
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.random.rawValue,
                radius: Float(relativeRadius),
                count: 0,
                angle: 0.0,
                position: CGPoint.zero.uniform
            )
        )
    }
}

