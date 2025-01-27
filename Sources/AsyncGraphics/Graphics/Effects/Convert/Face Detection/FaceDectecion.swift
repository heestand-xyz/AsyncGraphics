//
//  FaceDetection.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/27.
//

@preconcurrency import Vision
import CoreGraphicsExtensions

extension Graphic {
    
    public struct FaceDetection: Sendable {
        /// Original graphic resolution
        public let originalResolution: CGSize
        /// Frame relative to the original resolution
        public let frame: CGRect
        /// Cropped graphic with the face
        public let graphic: Graphic
        /// The observation from the Vision framework
        public let observation: VNFaceObservation
    }
    
    private struct Observation: Sendable {
        let face: VNFaceObservation
    }
    
    /// Detect faces in a graphic
    public func detectFaces() async throws -> [FaceDetection] {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: try await cgImage, options: [:])
        let observations: [Observation] = try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])
                if let results = request.results {
                    let observations = results.map(Observation.init)
                    continuation.resume(returning: observations)
                } else {
                    continuation.resume(returning: [])
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
        if observations.isEmpty { return [] }
        let frames: [CGRect] = observations.map(\.face.boundingBox).map { boundingBox in
            CGRect(origin: CGPoint(x: boundingBox.minX * resolution.width,
                                   y: (1.0 - boundingBox.maxY) * resolution.height),
                   size: boundingBox.size * resolution)
        }
        let graphics: [Graphic] = try await frames.asyncMap { frame in
            try await crop(to: frame)
        }
        return zip(observations, graphics).map { observation, graphic in
            FaceDetection(
                originalResolution: resolution,
                frame: observation.face.boundingBox,
                graphic: graphic,
                observation: observation.face
            )
        }
    }
}
