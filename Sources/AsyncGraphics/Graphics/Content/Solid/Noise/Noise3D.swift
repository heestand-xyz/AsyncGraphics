//
//  Created by Anton Heestand on 2022-04-27.
//

import Spatial

extension Graphic3D {
    
    private struct Noise3DUniforms {
        let colored: Bool
        let random: Bool
        let includeAlpha: Bool
        let seed: Int32
        let octaves: UInt32
        let position: VectorUniform
        let depth: Float
        let zoom: Float
        let tileOrigin: VectorUniform
        let tileSize: VectorUniform
    }
    
    /// Noise octaves are between 1 and 10
    public static func noise(offset: Point3D = .zero,
                             depth: Double = 0.0,
                             scale: Double = 1.0,
                             octaves: Int = 1,
                             seed: Int = 1,
                             resolution: Size3D,
                             tile: Tile = .one,
                             options: ContentOptions = []) async throws -> Graphic3D {
        
        let relativeOffset: Point3D = (offset - resolution / 2) / resolution.height
        
        let relativeDepth: Double = depth / resolution.height
        
        return try await Renderer.render(
            name: "Noise 3D",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: false,
                random: false,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: relativeOffset.uniform,
                depth: Float(relativeDepth),
                zoom: Float(scale),
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
    public static func transparantNoise(offset: Point3D = .zero,
                                        depth: Double = 0.0,
                                        scale: Double = 1.0,
                                        octaves: Int = 1,
                                        seed: Int = 1,
                                        resolution: Size3D,
                                        tile: Tile = .one,
                                        options: ContentOptions = []) async throws -> Graphic3D {
        
        let relativeOffset: Point3D = (offset - resolution / 2) / resolution.height
        
        let relativeDepth: Double = depth / resolution.height
        
        return try await Renderer.render(
            name: "Noise 3D",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: false,
                random: false,
                includeAlpha: true,
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: relativeOffset.uniform,
                depth: Float(relativeDepth),
                zoom: Float(scale),
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
    public static func coloredNoise(offset: Point3D = .zero,
                                    depth: Double = 0.0,
                                    scale: Double = 1.0,
                                    octaves: Int = 1,
                                    seed: Int = 1,
                                    resolution: Size3D,
                                    tile: Tile = .one,
                                    options: ContentOptions = []) async throws -> Graphic3D {
        
        let relativeOffset: Point3D = (offset - resolution / 2) / resolution.height
        
        let relativeDepth: Double = depth / resolution.height
        
        return try await Renderer.render(
            name: "Noise 3D (Colored)",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: true,
                random: false,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: relativeOffset.uniform,
                depth: Float(relativeDepth),
                zoom: Float(scale),
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
                                   resolution: Size3D,
                                   tile: Tile = .one,
                                   options: ContentOptions = []) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Noise 3D (Random)",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: false,
                random: true,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                depth: 0.0,
                zoom: 0.0,
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
                                          resolution: Size3D,
                                          tile: Tile = .one,
                                          options: ContentOptions = []) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Noise 3D (Random Colored)",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: true,
                random: true,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                depth: 0.0,
                zoom: 0.0,
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
