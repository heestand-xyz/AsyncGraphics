//
//  Created by Anton Heestand on 2022-04-21.
//

import Foundation
import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct UVColorParticlesColorUniform {
        let color: ColorUniform
    }
    
    private struct UVColorParticlesVertexUniform {
        let multiplyParticleSize: Bool
        let particleScale: Float
        let resolution: SizeUniform
    }
    
    public struct UVColorParticleOptions: OptionSet, Sendable {
        
        public let rawValue: Int
        
        public static let channelScale = UVColorParticleOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// UV Color Particles
    ///
    /// The number of particles is based on the number of input pixels (`count == width * height`).
    ///
    /// Particles **x & y** coordinate is based on the input pixel's **red & green** channels.
    /// Particle color is based on "with graphic".
    ///
    /// The coordinate space is **y up**. Black is in the center, red is towards the right and green is towards the top.
    /// To place particles in the left of bottom, you need a 16 bit graphic (option: `.highBitMode`) with negative colors.
    /// The height of the coordinate space is 1.0, to top is 0.5, and bottom is -0.5.
    /// The coordinate space is aspect correct, so far right will be over 0.5 in the red channel if your aspectRatio is above 1.0.
    ///
    /// Particles **size** is based on `particleScale` multiplied by the input pixel's **blue** channel, if `particleOptions` `channelScale` is selected.
    public func uvColorParticles(with graphic: Graphic,
                                 particleScale: CGFloat = 1.0,
                                 backgroundColor: PixelColor = .black,
                                 resolution: CGSize,
                                 sampleCount: UVParticleSampleCount = .one,
                                 particleOptions: UVColorParticleOptions = UVColorParticleOptions(),
                                 options: ContentOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "UV Color Particles",
            shader: .custom(fragment: "fragmentColor", vertex: "uvColorParticles"),
            graphics: [self, graphic],
            uniforms: UVColorParticlesColorUniform(
                color: PixelColor.white.uniform
            ),
            vertexUniforms: UVColorParticlesVertexUniform(
                multiplyParticleSize: particleOptions.contains(.channelScale),
                particleScale: Float(particleScale),
                resolution: self.resolution.uniform
            ),
            vertices: .indirect(count: self.resolution.count, type: .point),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                addressMode: .clampToEdge,
                clearColor: backgroundColor,
                additive: true,
                sampleCount: sampleCount.rawValue
            )
        )
    }
}
