//
//  LocationFromDepth.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-02-19.
//

import simd
import Foundation

extension Graphic {

    private struct LocationFromDepthPerspectiveUniforms: Uniforms {
        let inverseViewProjectionMatrix: matrix_float4x4
    }

    private struct LocationFromDepthOrthographicUniforms: Uniforms {
        let cameraWorldMatrix: matrix_float4x4
        let near: Float
        let far: Float
        let halfWidth: Float
        let halfHeight: Float
    }

    public enum LocationFromDepthError: String, LocalizedError {
        case nonInvertibleViewProjectionMatrix
        case invalidOrthographicDepthRange
        public var errorDescription: String? {
            switch self {
            case .nonInvertibleViewProjectionMatrix:
                "View-projection matrix is non-invertible."
            case .invalidOrthographicDepthRange:
                "Orthographic depth range is invalid."
            }
        }
    }

    public func locationFromDepth(
        viewProjectionMatrix: matrix_float4x4,
        options: EffectOptions = []
    ) async throws -> Graphic {

        let determinant: Float = simd_determinant(viewProjectionMatrix)
        guard determinant.isFinite, Swift.abs(determinant) > 0.000_000_1 else {
            throw LocationFromDepthError.nonInvertibleViewProjectionMatrix
        }

        let inverseViewProjectionMatrix: matrix_float4x4 = simd_inverse(viewProjectionMatrix)
        return try await locationFromDepth(
            inverseViewProjectionMatrix: inverseViewProjectionMatrix,
            options: options
        )
    }

    public func locationFromDepth(
        inverseViewProjectionMatrix: matrix_float4x4,
        options: EffectOptions = []
    ) async throws -> Graphic {

        try await Renderer.render(
            name: "Location from Depth",
            shader: .name("locationFromDepth"),
            graphics: [self],
            uniforms: LocationFromDepthPerspectiveUniforms(
                inverseViewProjectionMatrix: inverseViewProjectionMatrix
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: .linearSRGB,
                bits: ._32
            ),
            options: options.spatialRenderOptions
        )
    }

    public func locationFromDepthOrthographic(
        cameraWorldMatrix: matrix_float4x4,
        near: Float,
        far: Float,
        halfWidth: Float,
        halfHeight: Float,
        options: EffectOptions = []
    ) async throws -> Graphic {

        let depthRange: Float = far - near
        guard depthRange > 0.0, depthRange.isFinite else {
            throw LocationFromDepthError.invalidOrthographicDepthRange
        }

        return try await Renderer.render(
            name: "Location from Depth Orthographic",
            shader: .name("locationFromDepthOrthographic"),
            graphics: [self],
            uniforms: LocationFromDepthOrthographicUniforms(
                cameraWorldMatrix: cameraWorldMatrix,
                near: near,
                far: far,
                halfWidth: halfWidth,
                halfHeight: halfHeight
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: .linearSRGB,
                bits: ._32
            ),
            options: options.spatialRenderOptions
        )
    }
}
