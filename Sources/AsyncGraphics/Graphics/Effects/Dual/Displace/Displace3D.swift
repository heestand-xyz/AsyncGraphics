//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
import PixelColor

extension Graphic3D {
    
    private struct Displace3DUniforms {
        let offset: Float
        let origin: VectorUniform
        let placement: UInt32
    }
    
    @available(*, deprecated, renamed: "displaced(offset:origin:placement:options:graphic:)")
    public func displaced(with graphic: Graphic3D,
                          offset: Double,
                          origin: PixelColor = .gray,
                          placement: Placement = .fill,
                          options: EffectOptions = EffectOptions()) async throws -> Graphic3D {
        try await displaced(offset: offset, origin: origin, placement: placement, options: options) {
            graphic
        }
    }
    
    public func displaced(offset: Double,
                          origin: PixelColor = .gray,
                          placement: Placement = .fill,
                          options: EffectOptions = EffectOptions(),
                          graphic: () async throws -> Graphic3D) async throws -> Graphic3D {
        
        let relativeOffset: Double = offset / Double(height)
        
        return try await Renderer.render(
            name: "Displace",
            shader: .name("displace3d"),
            graphics: [
                self,
                graphic()
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
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
