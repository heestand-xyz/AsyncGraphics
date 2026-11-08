//
//  PhotoCamera+Readiness.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(macOS)
import Foundation
@preconcurrency import AVKit

extension Graphic.PhotoCamera {
    private static let captureReadinessTimeout: Duration = .seconds(5)

    /// Waits for the photo output to report that it is ready to capture.
    func waitForCaptureReadiness(output: AVCapturePhotoOutput) async throws(PhotoCameraError) {
        let observer: PhotoCaptureReadinessObserver = PhotoCaptureReadinessObserver()
        let coordinator: AVCapturePhotoOutputReadinessCoordinator = AVCapturePhotoOutputReadinessCoordinator(photoOutput: output)
        // Setting the delegate delivers the current readiness on the main queue.
        coordinator.delegate = observer
        defer {
            // The coordinator holds its delegate weakly.
            withExtendedLifetime(observer) { coordinator.delegate = nil }
        }
        let ready: AsyncStream<Void> = observer.ready
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await _ in ready { return }
                    throw CancellationError()
                }
                group.addTask {
                    try await Task.sleep(for: Self.captureReadinessTimeout)
                    throw PhotoCameraError.captureReadinessTimedOut
                }
                defer { group.cancelAll() }
                _ = try await group.next()
            }
        } catch is CancellationError {
            throw .cancelled
        } catch let error as PhotoCameraError {
            throw error
        } catch {
            throw .captureFailed(error)
        }
    }
}
#endif
