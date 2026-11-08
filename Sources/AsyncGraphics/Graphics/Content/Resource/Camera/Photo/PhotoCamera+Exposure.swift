//
//  PhotoCamera+Exposure.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(macOS)
import Foundation
@preconcurrency import AVKit

extension Graphic.PhotoCamera {
    private static let exposureTimeout: Duration = .seconds(5)

    func addExposureObserver(to session: AVCaptureSession) throws(PhotoCameraError) {
        let output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(output) else { throw .canNotAddOutput }
        session.addOutput(output)
        let observer: PhotoCaptureExposureObserver = PhotoCaptureExposureObserver()
        output.setSampleBufferDelegate(observer, queue: observer.queue)
        exposureOutput = output
        exposureObserver = observer
    }

    /// Waits for a streamed frame with settled auto exposure, since the photo
    /// is taken from the stream and the first frames after startup are black.
    func waitForSettledExposure() async throws(PhotoCameraError) {
        guard let exposureObserver else { throw .outputNotFound }
        let settled: AsyncStream<Void> = exposureObserver.settled
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await _ in settled { return }
                    throw CancellationError()
                }
                group.addTask {
                    try await Task.sleep(for: Self.exposureTimeout)
                    throw PhotoCameraError.exposureTimedOut
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
