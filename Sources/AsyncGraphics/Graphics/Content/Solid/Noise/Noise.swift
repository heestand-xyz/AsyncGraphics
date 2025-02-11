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
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }
    
    /// Noise octaves are between 1 and 10
    public static func noise(offset: CGPoint = .zero,
                             depth: CGFloat = 0.0,
                             scale: CGFloat = 1.0,
                             octaves: Int = 1,
                             seed: Int = 1,
                             resolution: CGSize,
                             tile: Tile = .one,
                             options: ContentOptions = []) async throws -> Graphic {
        
        let relativeOffset: CGPoint = (offset - resolution / 2) / resolution.height
        
        let relativeDepth: CGFloat = depth / resolution.height
        
        return try await Renderer.render(
            name: "Noise",
            shader: .name("noise"),
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: UInt32(max(1, octaves)),
                position: VectorUniform(
                    x: Float(relativeOffset.x),
                    y: Float(relativeOffset.y),
                    z: Float(relativeDepth)
                ),
                zoom: Float(scale),
                colored: false,
                random: false,
                includeAlpha: false,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    /// Noise octaves are between 1 and 10
    public static func coloredNoise(offset: CGPoint = .zero,
                                    depth: CGFloat = 0.0,
                                    scale: CGFloat = 1.0,
                                    octaves: Int = 1,
                                    seed: Int = 1,
                                    resolution: CGSize,
                                    tile: Tile = .one,
                                    options: ContentOptions = []) async throws -> Graphic {
        
        let relativeOffset: CGPoint = (offset - resolution / 2) / resolution.height
        
        let relativeDepth: CGFloat = depth / resolution.height
        
        return try await Renderer.render(
            name: "Noise (Colored)",
            shader: .name("noise"),
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
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func randomNoise(seed: Int = 1,
                                   resolution: CGSize,
                                   tile: Tile = .one,
                                   options: ContentOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Noise (Random)",
            shader: .name("noise"),
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                zoom: 0.0,
                colored: false,
                random: true,
                includeAlpha: false,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func randomColoredNoise(seed: Int = 1,
                                          resolution: CGSize,
                                          tile: Tile = .one,
                                          options: ContentOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Noise (Random Colored)",
            shader: .name("noise"),
            uniforms: NoiseUniforms(
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                zoom: 0.0,
                colored: true,
                random: true,
                includeAlpha: false,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
