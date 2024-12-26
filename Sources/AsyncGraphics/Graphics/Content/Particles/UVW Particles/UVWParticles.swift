////
////  Created by Anton Heestand on 2023-12-03.
////
//
//import Foundation
//import Spatial
//import CoreGraphics
//import PixelColor
//
//extension Graphic3D {
//    
//    private struct UVWParticlesColorUniform {
//        let color: ColorUniform
//    }
//    
//    private struct UVWParticlesVertexUniform {
//        let multiplyParticleAlpha: Bool
//        let clipParticleAlpha: Bool
//        let particleScale: Float
//        let resolution: VectorUniform
//    }
//    
//    public struct UVWParticleOptions: OptionSet, Sendable {
//        
//        public let rawValue: Int
//        
//        public static let channelAlpha = UVWParticleOptions(rawValue: 1 << 1)
//        public static let clipChannelAlpha = UVWParticleOptions(rawValue: 1 << 2)
//
//        public init(rawValue: Int) {
//            self.rawValue = rawValue
//        }
//    }
//    
//    /// UVW Particles
//    ///
//    /// The number of particles is based on the number of input voxels (`count == width * height * depth`).
//    ///
//    /// Particles **x, y and z** coordinate is based on the input voxel's **red, green and blue** channels.
//    ///
//    /// The coordinate space is **y up**. Black is in the center, red is towards the right and green is towards the top.
//    /// To place particles in the left of bottom, you need a 16 bit graphic (option: `.highBitMode`) with negative colors.
//    /// The height of the coordinate space is 1.0, to top is 0.5, and bottom is -0.5.
//    /// The coordinate space is aspect correct, so far right will be over 0.5 in the red channel if your aspectRatio is above 1.0.
//    ///
//    /// Particles **size** is based on `particleScale`.
//    ///
//    /// Particles **alpha** is based on `color` multiplied by the input pixel's **alpha** channel, if `particleOptions` `channelAlphaEnabled` is selected.
//    ///
//    /// If `particleOptions` `clipChannelAlpha` is selected,  then particles with alpha less than `1.0` will be hidden.
//    public func uvwParticles(particleScale: CGFloat = 1.0,
//                             particleColor: PixelColor = .white,
//                             backgroundColor: PixelColor = .black,
//                             resolution: Size3D,
//                             particleOptions: UVWParticleOptions = UVWParticleOptions(),
//                             options: ContentOptions = []) async throws -> Graphic3D {
//        
//        try await Renderer.render(
//            name: "UVW Particles",
//            shader: .custom(fragment: "fragmentColor", vertex: "uvwParticles"),
//            graphics: [self],
//            uniforms: UVWParticlesColorUniform(
//                color: particleColor.uniform
//            ),
//            vertexUniforms: UVWParticlesVertexUniform(
//                multiplyParticleAlpha: particleOptions.contains(.channelAlpha) || particleOptions.contains(.clipChannelAlpha),
//                clipParticleAlpha: particleOptions.contains(.clipChannelAlpha),
//                particleScale: Float(particleScale),
//                resolution: self.resolution.uniform
//            ),
//            vertices: .indirect(count: self.voxelCount, type: .point),
//            metadata: Renderer.Metadata(
//                resolution: resolution,
//                colorSpace: options.colorSpace,
//                bits: options.bits
//            ),
//            options: Renderer.Options(
//                addressMode: .clampToZero,
//                filter: options.contains(.pixelated) ? .nearest : .linear,
//                clearColor: backgroundColor,
//                additive: true
//            )
//        )
//    }
//}
