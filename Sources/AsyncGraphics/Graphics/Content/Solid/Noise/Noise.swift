//
//  Created by Anton Heestand on 2022-04-19.
//

import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    private struct NoiseUniforms {
        let seed: Int32
        let octaves: UInt32
        let position: VectorUniform
        let zoom: Float
        let colored: Bool
        let random: Bool
        let includeAlpha: Bool
        let resolution: SizeUniform
    }
    
    /// Noise octaves are between 1 and 10
    public static func noise(
        offset: CGPoint = .zero,
        depth: CGFloat = 0.0,
        scale: CGFloat = 1.0,
        octaves: Int = 1,
        seed: Int = 1,
        at graphicSize: CGSize
    ) async throws -> Graphic {
        
        let offset: CGPoint = offset.flipPositionY(size: graphicSize)
        let relativeOffset: CGPoint = (offset - graphicSize / 2) / graphicSize.height
        
        let relativeDepth: CGFloat = depth / graphicSize.height
        
        return try await Renderer.render(
            name: "Noise",
            shaderName: "noise",
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: VectorUniform(
                    x: Float(relativeOffset.x),
                    y: Float(relativeOffset.y),
                    z: Float(relativeDepth)
                ),
                zoom: Float(scale),
                colored: false,
                random: false,
                includeAlpha: false,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
    
    /// Noise octaves are between 1 and 10
    public static func coloredNoise(
        offset: CGPoint = .zero,
        depth: CGFloat = 0.0,
        scale: CGFloat = 1.0,
        octaves: Int = 1,
        seed: Int = 1,
        at graphicSize: CGSize
    ) async throws -> Graphic {
        
        let offset: CGPoint = offset.flipPositionY(size: graphicSize)
        let relativeOffset: CGPoint = (offset - graphicSize / 2) / graphicSize.height
        
        let relativeDepth: CGFloat = depth / graphicSize.height
        
        return try await Renderer.render(
            name: "Noise (Colored)",
            shaderName: "noise",
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: VectorUniform(
                    x: Float(relativeOffset.x),
                    y: Float(relativeOffset.y),
                    z: Float(relativeDepth)
                ),
                zoom: Float(scale),
                colored: true,
                random: false,
                includeAlpha: false,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
    
    public static func randomNoise(
        seed: Int = 1,
        at graphicSize: CGSize
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Noise (Random)",
            shaderName: "noise",
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                zoom: 0.0,
                colored: false,
                random: true,
                includeAlpha: false,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
    
    public static func randomColoredNoise(
        seed: Int = 1,
        at graphicSize: CGSize
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Noise (Random Colored)",
            shaderName: "noise",
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                zoom: 0.0,
                colored: true,
                random: true,
                includeAlpha: false,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
}
