import Foundation
import AVFoundation
import Testing
@testable import AsyncGraphics

@Suite("Camera Interruption Events")
struct CameraInterruptionEventsTests {
    typealias State = Graphic.Camera.InterruptionState

    @Test("Only the exact session is observed, in notification delivery order")
    func sessionIdentityAndOrdering() async {
        let center = NotificationCenter()
        let session = NSObject()
        let foreignSession = NSObject()
        let source = CameraInterruptionEvents(session: session, center: center)
        let stream = source.stream()
        source.beginObserving()
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: foreignSession,
                    userInfo: reasonInfo(17))
        for index in 0..<20 {
            center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                        userInfo: reasonInfo(index))
            center.post(name: AVCaptureSession.interruptionEndedNotification, object: session)
        }
        // A foreign end must not clear this session's last interruption.
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(99))
        center.post(name: AVCaptureSession.interruptionEndedNotification, object: foreignSession)
        source.finish()
        var expected: [State] = [.notInterrupted]
        for index in 0..<20 {
            expected += [interrupted(index), .notInterrupted]
        }
        expected.append(interrupted(99))
        #expect(await collect(stream) == expected)
    }

    @Test("Missing and unknown reasons use the native enum conversion")
    func nativeReasonConversion() async {
        let center = NotificationCenter()
        let session = NSObject()
        let source = CameraInterruptionEvents(session: session, center: center)
        let stream = source.stream()
        source.beginObserving()
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(4))
        center.post(name: AVCaptureSession.interruptionEndedNotification, object: session)
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session)
        center.post(name: AVCaptureSession.interruptionEndedNotification, object: session)
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(999))
        source.finish()
#if os(iOS) || os(tvOS) || os(visionOS)
        #expect(await collect(stream) == [
            .notInterrupted, .interrupted(reason: .videoDeviceNotAvailableWithMultipleForegroundApps),
            .notInterrupted, .interrupted(reason: nil), .notInterrupted,
            .interrupted(reason: AVCaptureSession.InterruptionReason(rawValue: 999))
        ])
#else
        #expect(await collect(stream) == [
            .notInterrupted, .interrupted, .notInterrupted, .interrupted, .notInterrupted, .interrupted
        ])
#endif
    }

    @Test("Late subscriptions receive the interruption observed during startup")
    func startupAndLateSnapshot() async {
        let center = NotificationCenter()
        let session = NSObject()
        let source = CameraInterruptionEvents(session: session, center: center)
        source.beginObserving()
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(17))
        let lateSubscription = source.stream()
        // Repeated start requests must preserve an existing interruption.
        source.beginObserving()
        center.post(name: AVCaptureSession.interruptionEndedNotification, object: session)
        source.finish()
        #expect(await collect(lateSubscription) == [interrupted(17), .notInterrupted])
    }

    @Test("Stopped runs reset state and stale callbacks cannot alter a restarted run")
    func stopRestartAndStaleCallback() async throws {
        let center = NotificationCenter()
        let session = NSObject()
        let source = CameraInterruptionEvents(session: session, center: center)
        let stream = source.stream()
        let oldGeneration: UUID = try #require(source.beginObserving())
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(1))
        source.stopObserving()
        // These arrive while stopped and must not be replayed on restart.
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(2))
        let newGeneration: UUID = try #require(source.beginObserving())
        #expect(newGeneration != oldGeneration)
        // Exercise the same ingress as an observer already in flight at removal.
        source.enqueue(interrupted(3), generation: oldGeneration)
        source.enqueue(interrupted(4), generation: newGeneration)
        source.enqueue(.notInterrupted, generation: oldGeneration)
        source.finish()
        #expect(await collect(stream) == [
            .notInterrupted, interrupted(1), .notInterrupted, interrupted(4)
        ])
    }

    @Test("Canceling one consumer does not stop observation or another subscription")
    func subscriberCancellation() async {
        let center = NotificationCenter()
        let session = NSObject()
        let source = CameraInterruptionEvents(session: session, center: center)
        let canceledStream = source.stream()
        let remainingStream = source.stream()
        source.beginObserving()
        let consumer = Task {
            for await _ in canceledStream {}
        }
        consumer.cancel()
        await consumer.value
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(17))
        source.finish()
        #expect(await collect(remainingStream) == [.notInterrupted, interrupted(17)])
        #expect(source.beginObserving() == nil)
        #expect(await collect(source.stream()).isEmpty)
    }

    @Test("Finishing is idempotent and releasing the source ends active streams")
    func releaseAndCleanup() async {
        let center = NotificationCenter()
        let session = NSObject()
        var source: CameraInterruptionEvents? = CameraInterruptionEvents(session: session, center: center)
        let stream = source!.stream()
        source!.beginObserving()
        weak var weakSource = source
        source = nil
        #expect(weakSource == nil)
        center.post(name: AVCaptureSession.wasInterruptedNotification, object: session,
                    userInfo: reasonInfo(17))
        #expect(await collect(stream) == [.notInterrupted])

        let finishedSource = CameraInterruptionEvents(session: session, center: center)
        let finishedStream = finishedSource.stream()
        finishedSource.finish()
        finishedSource.finish()
        finishedSource.stopObserving()
        #expect(await collect(finishedStream) == [.notInterrupted])
        #expect(await collect(finishedSource.stream()).isEmpty)
    }

    private func collect(_ stream: AsyncStream<State>) async -> [State] {
        var result: [State] = []
        for await value in stream { result.append(value) }
        return result
    }

    private func reasonInfo(_ code: Int) -> [AnyHashable: Any] {
#if os(iOS) || os(tvOS) || os(visionOS)
        [AVCaptureSessionInterruptionReasonKey: NSNumber(value: code)]
#else
        [:]
#endif
    }

    private func interrupted(_ code: Int) -> State {
#if os(iOS) || os(tvOS) || os(visionOS)
        .interrupted(reason: AVCaptureSession.InterruptionReason(rawValue: code))
#else
        .interrupted
#endif
    }
}
