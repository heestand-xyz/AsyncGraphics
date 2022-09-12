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
    
    public struct UVParticleOptions: OptionSet {
        
        public let rawValue: Int
        
        public static let channelScale = UVParticleOptions(rawValue: 1 << 0)
        public static let channelAlpha = UVParticleOptions(rawValue: 1 << 1)
        public static let clipChannelAlpha = UVParticleOptions(rawValue: 1 << 2)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public enum UVParticleSampleCount: Int {
        case one = 1
        case two = 2
        case four = 4
    }
    
    /// UV Particles
    ///
    /// The number of particles is based on the number of input pixels (`count == width * height`).
    ///
    /// Particles **x & y** coordinate is based on the input pixel's **red & green** channels.
    ///
    /// The coordinate space is **y up**. Black is in the center, red is towards the right and green is towards the top.
    /// To place particles in the left of bottom, you need a 16 bit graphic (option: `.highBitMode`) with negative colors.
    /// The height of the coordinate space is 1.0, to top is 0.5, and bottom is -0.5.
    /// The coordinate space is aspect correct, so far right will be over 0.5 in the red channel if your aspectRatio is above 1.0.
    ///
    /// Particles **size** is based on `particleScale` multiplied by the input pixel's **blue** channel, if `particleOptions` `channelScale` is selected.
    ///
    /// Particles **alpha** is based on `color` multiplied by the input pixel's **alpha** channel, if `particleOptions` `channelAlphaEnabled` is selected.
    ///
    /// If `particleOptions` `clipChannelAlpha` is selected,  then particles with alpha less than `1.0` will be hidden.
    public func uvParticles(particleScale: CGFloat = 1.0,
                            particleColor: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            sampleCount: UVParticleSampleCount = .one,
                            particleOptions: UVParticleOptions = UVParticleOptions(),
                            options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "UV Particles",
            shader: .custom(fragment: "fragmentColor", vertex: "uvParticles"),
            graphics: [self],
            uniforms: UVParticlesColorUniform(
                color: particleColor.uniform
            ),
            vertexUniforms: UVParticlesVertexUniform(
                multiplyParticleSize: particleOptions.contains(.channelScale),
                multiplyParticleAlpha: particleOptions.contains(.channelAlpha) || particleOptions.contains(.clipChannelAlpha),
                clipParticleAlpha: particleOptions.contains(.clipChannelAlpha),
                particleScale: Float(particleScale),
                resolution: self.resolution.uniform
            ),
            vertices: .indirect(count: resolution.count, type: .point),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                addressMode: .clampToZero,
                clearColor: backgroundColor,
                additive: true,
                sampleCount: sampleCount.rawValue
            )
        )
    }
}
