//
//  LUT3D.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-06-30.
//

import Foundation
import Spatial

extension Graphic3D {

    private struct LUT3DUniforms: Uniforms {
        let size: Int32
        let layout: UInt32
    }

    /// 2D to 3D
    ///
    /// Maps a 2D LUT graphic (square or linear layout) into a 3D color cube
    /// with a `size` by `size` by `size` resolution.
    public static func convertedLUT(
        with graphic: Graphic,
        layout: Graphic.LUTLayout
    ) async throws -> Graphic3D {

        let size: Int = try graphic.sizeOfLUT()

        let resolution = Size3D(width: Double(size), height: Double(size), depth: Double(size))

        return try await Renderer.render(
            name: "LUT 2D to 3D",
            shader: .name("lut2dTo3d"),
            graphics: [
                graphic
            ],
            uniforms: LUT3DUniforms(
                size: Int32(size),
                layout: layout == .square ? 0 : 1
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: graphic.colorSpace,
                bits: graphic.bits
            ),
            options: Renderer.Options(
                filter: .nearest
            )
        )
    }

    /// 3D to 2D
    ///
    /// Maps a 3D color cube back into a 2D LUT graphic.
    /// The layout is chosen based on the cube's `size`.
    public func convertedLUT() async throws -> (graphic: Graphic, layout: Graphic.LUTLayout) {

        guard resolution.width == resolution.height,
              resolution.width == resolution.depth else {
            throw Graphic.LUTError.resolutionUnknown
        }

        let size = Int(resolution.width)

        let layout: Graphic.LUTLayout = Graphic.idealLayoutOfLUT(size: size)

        let resolution: CGSize
        switch layout {
        case .square:
            let blockCount = Int(Double(size).squareRoot())
            let squareWidth = blockCount * size
            resolution = CGSize(width: squareWidth, height: squareWidth)
        case .linear:
            resolution = CGSize(width: size * size, height: size)
        }

        let graphic: Graphic = try await Renderer.render(
            name: "LUT 3D to 2D",
            shader: .name("lut3dTo2d"),
            graphics: [
                self
            ],
            uniforms: LUT3DUniforms(
                size: Int32(size),
                layout: layout == .square ? 0 : 1
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                filter: .nearest
            )
        )

        return (graphic, layout)
    }
}
