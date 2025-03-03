//
//  LumaSample3D.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/03/03.
//

import CoreGraphics

extension [Graphic] {
    
    public func lumaSampled(
        with graphic: Graphic,
        options: Graphic.EffectOptions = []
    ) async throws -> Graphic {
        try await merge().lumaSampled(with: graphic, options: options)
    }
}

extension Graphic3D {

    public func lumaSampled(
        with graphic: Graphic,
        options: Graphic.EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Luma Sample",
            shader: .name("lumaSample"),
            graphics: [
                graphic,
                self
            ],
            metadata: Renderer.Metadata(
                resolution: CGSize(width: width, height: height),
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter,
                targetSourceTexture: options.contains(.replace)
            )
        )
    }
}
