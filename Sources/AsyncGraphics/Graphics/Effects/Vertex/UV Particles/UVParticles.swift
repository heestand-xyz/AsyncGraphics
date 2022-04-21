//
//  Created by Anton Heestand on 2022-04-21.
//

import Foundation
import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct UVParticlesColorUniform {
        let color: ColorUniform
    }
    
    private struct UVParticlesVertexUniform {
        let multiplyParticleSize: Bool
        let multiplyParticleAlpha: Bool
        let clipParticleAlpha: Bool
        let particleScale: Float
        let resolution: SizeUniform
    }
    
    public struct UVParticleOptions {
        let channelScaleEnabled: Bool
        let channelAlphaEnabled: Bool
        let clipChannelAlpha: Bool
        public init(channelScaleEnabled: Bool = false,
                    channelAlphaEnabled: Bool = false,
                    clipChannelAlpha: Bool = false) {
            self.channelScaleEnabled = channelScaleEnabled
            self.channelAlphaEnabled = channelAlphaEnabled
            self.clipChannelAlpha = clipChannelAlpha
        }
    }
    
    /// UV Particles
    ///
    /// The number of particles is based on the number of input pixels (`count == width * height`).
    ///
    /// Particles **x & y** coordinate is based on the input pixel's **red & green** channels.
    ///
    /// The coordinate space is **y up**. Black is in the center, red is towards the right and green is towards the top.
    /// To place particles in the left of bottom, you need a 16 bit graphic with negative colors.
    /// The height of the coordinate space is 1.0, to top is 0.5, and bottom is -0.5.
    /// The coordinate space is aspect correct, so far right will be over 0.5 in the red channel if your aspectRatio is above 1.0.
    ///
    /// Particles **size** is based on `particleScale` multiplied by the input pixel's **blue** channel, if `particleOptions.channelScaleEnabled` is `true`.
    ///
    /// Particles **alpha** is based on `color` multiplied by the input pixel's **alpha** channel, if `particleOptions.channelAlphaEnabled` is `true`.
    ///
    /// If `particleOptions.clipChannelAlpha` is `true`, (`particleOptions.channelAlphaEnabled` required), then particles with alpha less than `1.0` will be hidden.
    public func uvParticles(particleScale: CGFloat = 1.0,
                            particleColor: PixelColor = .white,
                            particleOptions: UVParticleOptions = UVParticleOptions(),
                            backgroundColor: PixelColor = .black,
                            at graphicSize: CGSize) async throws -> Graphic {
        
        try await Renderer.render(
            name: "UV Particles",
            shader: .custom(fragment: "vertexColor", vertex: "uvParticles"),
            graphics: [self],
            uniforms: UVParticlesColorUniform(
                color: particleColor.uniform
            ),
            vertexUniforms: UVParticlesVertexUniform(
                multiplyParticleSize: particleOptions.channelScaleEnabled,
                multiplyParticleAlpha: particleOptions.channelAlphaEnabled,
                clipParticleAlpha: particleOptions.clipChannelAlpha,
                particleScale: Float(particleScale),
                resolution: resolution.uniform
            ),
            vertexCount: resolution.count,
            metadata: Renderer.Metadata(
                resolution: graphicSize.resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(clearColor: backgroundColor)
        )
    }
}
