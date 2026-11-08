//
//  PhotoCaptureReadinessObserver.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(macOS)
import Foundation
import AVFoundation

/// Reports when the photo output first becomes ready to capture.
final class PhotoCaptureReadinessObserver: NSObject, AVCapturePhotoOutputReadinessCoordinatorDelegate, Sendable {
    let ready: AsyncStream<Void>
    private let continuation: AsyncStream<Void>.Continuation

    override init() {
        let stream: (stream: AsyncStream<Void>, continuation: AsyncStream<Void>.Continuation) = AsyncStream.makeStream(
            of: Void.self, bufferingPolicy: .bufferingNewest(1)
        )
        ready = stream.stream
        continuation = stream.continuation
        super.init()
    }

    func readinessCoordinator(
        _ coordinator: AVCapturePhotoOutputReadinessCoordinator,
        captureReadinessDidChange captureReadiness: AVCapturePhotoOutput.CaptureReadiness
    ) {
        guard captureReadiness == .ready else { return }
        continuation.yield()
        continuation.finish()
    }
}
#endif
