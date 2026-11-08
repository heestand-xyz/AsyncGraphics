//
//  PhotoCaptureExposureObserver.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(macOS)
import Foundation
import AVFoundation

/// Reports the first streamed frame whose auto exposure has settled.
///
/// A macOS photo is taken from the video stream, so a photo requested before
/// auto exposure converges is dark, or black during the first frames.
final class PhotoCaptureExposureObserver: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, Sendable {
    private static let metadataAttachmentKey: String = "MetadataDictionary"
    private static let exposureStableKey: String = "AEStable"
    private static let exposureLimitsReachedKey: String = "AELimitsReached"

    let queue: DispatchQueue = DispatchQueue(label: "async-graphics.photo-camera.exposure")
    let settled: AsyncStream<Void>
    private let continuation: AsyncStream<Void>.Continuation

    override init() {
        let stream: (stream: AsyncStream<Void>, continuation: AsyncStream<Void>.Continuation) = AsyncStream.makeStream(
            of: Void.self, bufferingPolicy: .bufferingNewest(1)
        )
        settled = stream.stream
        continuation = stream.continuation
        super.init()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard Self.isExposureSettled(sampleBuffer) else { return }
        continuation.yield()
        continuation.finish()
    }

    /// Apple cameras attach their auto exposure state to every frame. Exposure
    /// is settled once it is stable, or at its limits in very dark or bright
    /// scenes. Cameras without this state are settled on their first frame.
    private static func isExposureSettled(_ sampleBuffer: CMSampleBuffer) -> Bool {
        guard let metadata: [String: Any] = CMGetAttachment(
            sampleBuffer, key: metadataAttachmentKey as CFString, attachmentModeOut: nil
        ) as? [String: Any], let isStable: Bool = metadata[exposureStableKey] as? Bool else {
            return true
        }
        let isAtLimits: Bool = (metadata[exposureLimitsReachedKey] as? Bool) ?? false
        return isStable || isAtLimits
    }
}
#endif
