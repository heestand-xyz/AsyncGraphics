//
//  StackArray3D.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-09-25.
//

import Foundation
import Spatial
import PixelColor

extension Graphic3D {

    public enum StackError: LocalizedError {
        case noGraphicsProvided

        public var errorDescription: String? {
            "Provide at least one 3D graphic to stack."
        }
    }

    public static func hStacked(
        with graphics: [Graphic3D],
        yAlignment: Alignment3D.Y = .center,
        zAlignment: Alignment3D.Z = .center,
        spacing: Double = 0.0,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        guard var result = graphics.first else {
            throw StackError.noGraphicsProvided
        }
        for graphic in graphics.dropFirst() {
            result = try await result.hStacked(
                with: graphic,
                yAlignment: yAlignment,
                zAlignment: zAlignment,
                spacing: spacing,
                options: options
            )
        }
        return result
    }

    public static func vStacked(
        with graphics: [Graphic3D],
        xAlignment: Alignment3D.X = .center,
        zAlignment: Alignment3D.Z = .center,
        spacing: Double = 0.0,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        guard var result = graphics.first else {
            throw StackError.noGraphicsProvided
        }
        for graphic in graphics.dropFirst() {
            result = try await result.vStacked(
                with: graphic,
                xAlignment: xAlignment,
                zAlignment: zAlignment,
                spacing: spacing,
                options: options
            )
        }
        return result
    }

    public static func dStacked(
        with graphics: [Graphic3D],
        xAlignment: Alignment3D.X = .center,
        yAlignment: Alignment3D.Y = .center,
        spacing: Double = 0.0,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        guard var result = graphics.first else {
            throw StackError.noGraphicsProvided
        }
        for graphic in graphics.dropFirst() {
            result = try await result.dStacked(
                with: graphic,
                xAlignment: xAlignment,
                yAlignment: yAlignment,
                spacing: spacing,
                options: options
            )
        }
        return result
    }

    /// Overlay volumes at their original voxel sizes, preserving the first volume's color and opacity.
    public static func layered(
        with graphics: [Graphic3D],
        blendingMode: Graphic.BlendMode = .over,
        alignment: Alignment3D = .center,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        guard let first = graphics.first else {
            throw StackError.noGraphicsProvided
        }
        let resolution = graphics.reduce(Size3D.zero) { result, graphic in
            Size3D(width: max(result.width, graphic.resolution.width),
                   height: max(result.height, graphic.resolution.height),
                   depth: max(result.depth, graphic.resolution.depth))
        }
        let contentOptions: ContentOptions = switch first.bits {
        case ._8: []
        case ._16: .bit16
        case ._32: .bit32
        }
        var result = try await Graphic3D.color(.clear, resolution: resolution, options: contentOptions)
        for (index, graphic) in graphics.enumerated() {
            // Add over clear copies the first volume without multiplying its RGB by alpha again.
            result = try await result.blended(
                with: graphic,
                blendingMode: index == 0 ? .add : blendingMode,
                placement: .fixed,
                alignment: alignment,
                options: options
            )
        }
        return result
    }
}
