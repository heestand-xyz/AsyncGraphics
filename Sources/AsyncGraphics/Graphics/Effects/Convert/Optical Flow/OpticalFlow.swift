//
//  OpticalFlow.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-08-04.
//

// FIXME: `VNGenerateOpticalFlowRequest` is technically supported on macOS, tho crashes on `try handler.perform([request])`.
#if !os(macOS)

import Vision
import TextureMap
import CoreVideo

extension Graphic {
    
    @EnumMacro
    public enum OpticalFlowAccuracy: String, GraphicEnum {
        case low
        case medium
        case high
        case veryHigh
        var accuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy {
            switch self {
            case .low: .low
            case .medium: .medium
            case .high: .high
            case .veryHigh: .veryHigh
            }
        }
    }
    
    enum OpticalFlowError: String, LocalizedError {
        case opticalFlowRequestFailed
        var errorDescription: String? {
            switch self {
            case .opticalFlowRequestFailed:
                "Optical flow request failed."
            }
        }
    }
    
    public static func opticalFlow(
        withPrevious source: Graphic,
        withCurrent target: Graphic,
        accuracy: OpticalFlowAccuracy = .high
    ) async throws -> Graphic {
        
        let sourcePixelBuffer: CVPixelBuffer = try await source.withBits(.bit8).pixelBuffer
        let targetPixelBuffer: CVPixelBuffer = try await target.withBits(.bit8).pixelBuffer

        let request = VNGenerateOpticalFlowRequest(targetedCVPixelBuffer: targetPixelBuffer, options: [:])
        request.computationAccuracy = accuracy.accuracy
        request.outputPixelFormat = kCVPixelFormatType_TwoComponent32Float

        let handler = VNImageRequestHandler(cvPixelBuffer: sourcePixelBuffer, options: [:])
        try handler.perform([request])

        guard let result = request.results?.first as? VNPixelBufferObservation else {
            throw OpticalFlowError.opticalFlowRequestFailed
        }

        let texture = try TextureMap.texture(pixelBuffer: result.pixelBuffer)
        
        return try await Graphic(
            name: "Optical Flow",
            texture: texture,
            bits: ._32,
            colorSpace: .linearSRGB
        )
        .channelMix(red: .red, green: .green, blue: .zero, alpha: .one)
    }
}

#endif
