//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
import PixelColor

extension Graphic3D {
    
    private struct Displace3DUniforms: Uniforms {
        let offset: Float
        let origin: VectorUniform
        let placement: UInt32
    }
    
    public func displaced(
        with graphic: Graphic3D,
        offset: Double,
        origin: PixelColor = .rawGray,
        placement: Graphic.Placement = .fill,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let relativeOffset: Double = offset / Double(height)
        
        return try await Renderer.render(
            name: "Displace 3D",
            shader: .name("displace3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: Displace3DUniforms(
                offset: Float(relativeOffset),
                origin: VectorUniform(
                    x: Float(origin.red),
                    y: Float(origin.green),
                    z: Float(origin.blue)
                ),
                placement: placement.index
            ),
            options: options.spatialRenderOptions
        )
    }
}
