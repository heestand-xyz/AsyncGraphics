//
//  Created by Anton Heestand on 2022-04-27.
//

import simd

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
    }
    
    /// Noise octaves are between 1 and 10
    public static func noise(offset: SIMD3<Double> = .zero,
                             depth: Double = 0.0,
                             scale: Double = 1.0,
                             octaves: Int = 1,
                             seed: Int = 1,
                             resolution: SIMD3<Int>,
                             options: ContentOptions = []) async throws -> Graphic3D {
        
        let relativeOffset: SIMD3<Double> = (offset - resolution.asDouble / 2) / Double(resolution.y)
        
        let relativeDepth: Double = depth / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Noise",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: false,
                random: false,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: relativeOffset.uniform,
                depth: Float(relativeDepth),
                zoom: Float(scale)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    /// Noise octaves are between 1 and 10
    public static func transparantNoise(offset: SIMD3<Double> = .zero,
                                        depth: Double = 0.0,
                                        scale: Double = 1.0,
                                        octaves: Int = 1,
                                        seed: Int = 1,
                                        resolution: SIMD3<Int>,
                                        options: ContentOptions = []) async throws -> Graphic3D {
        
        let relativeOffset: SIMD3<Double> = (offset - resolution.asDouble / 2) / Double(resolution.y)
        
        let relativeDepth: Double = depth / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Noise",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: false,
                random: false,
                includeAlpha: true,
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: relativeOffset.uniform,
                depth: Float(relativeDepth),
                zoom: Float(scale)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    /// Noise octaves are between 1 and 10
    public static func coloredNoise(offset: SIMD3<Double> = .zero,
                                    depth: Double = 0.0,
                                    scale: Double = 1.0,
                                    octaves: Int = 1,
                                    seed: Int = 1,
                                    resolution: SIMD3<Int>,
                                    options: ContentOptions = []) async throws -> Graphic3D {
        
        let relativeOffset: SIMD3<Double> = (offset - resolution.asDouble / 2) / Double(resolution.y)
        
        let relativeDepth: Double = depth / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Noise (Colored)",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: true,
                random: false,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: UInt32(octaves),
                position: relativeOffset.uniform,
                depth: Float(relativeDepth),
                zoom: Float(scale)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func randomNoise(seed: Int = 1,
                                   resolution: SIMD3<Int>,
                                   options: ContentOptions = []) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Noise (Random)",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: false,
                random: true,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                depth: 0.0,
                zoom: 0.0
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func randomColoredNoise(seed: Int = 1,
                                          resolution: SIMD3<Int>,
                                          options: ContentOptions = []) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Noise (Random Colored)",
            shader: .name("noise3d"),
            uniforms: Noise3DUniforms(
                colored: true,
                random: true,
                includeAlpha: false,
                seed: Int32(seed),
                octaves: 0,
                position: .zero,
                depth: 0.0,
                zoom: 0.0
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
