//
//  CameraInterruptionEvents.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-03.
//

import Foundation
@preconcurrency import AVFoundation

extension Graphic.Camera {
    /// Interruption state of this camera's private capture session.
    public enum InterruptionState: Equatable, Sendable {
        /// No interruption is known. This does not imply capture has started,
        /// is running, or has produced a frame. Also emitted when capture stops.
        case notInterrupted
#if os(iOS) || os(tvOS) || os(visionOS)
        /// The OS reason, or nil when missing or not convertible to the SDK enum.
        case interrupted(reason: AVCaptureSession.InterruptionReason?)
#else
        /// Interruption reasons are unavailable on macOS.
        case interrupted
#endif
    }
}

/// Notification callbacks enqueue onto one serial queue, rather than spawning
/// independent Tasks. All mutable state and stream delivery stay on that queue.
/// No capture-session methods or consumer callbacks execute on the queue.
final class CameraInterruptionEvents: @unchecked Sendable {
    typealias State = Graphic.Camera.InterruptionState

    private let session: NSObject
    private let center: NotificationCenter
    private let queue = DispatchQueue(label: "async-graphics.camera.interruptions")
    private let queueKey = DispatchSpecificKey<UInt8>()
    private var currentState: State = .notInterrupted
    private var generation: UUID?
    private var isFinished: Bool = false
    private var observers: [NSObjectProtocol] = []
    private var continuations: [UUID: AsyncStream<State>.Continuation] = [:]

    init(session: NSObject, center: NotificationCenter = .default) {
        self.session = session
        self.center = center
        queue.setSpecific(key: queueKey, value: 1)
    }

    deinit { finish() }

    func stream() -> AsyncStream<State> {
        let id: UUID = UUID()
        let pair = AsyncStream<State>.makeStream()
        pair.continuation.onTermination = { [weak self] _ in
            guard let self else { return }
            // finish/yield may synchronously invoke termination; never reenter
            // state mutation or wait for this queue from a termination handler.
            queue.async { [weak self] in self?.continuations.removeValue(forKey: id) }
        }
        onQueue {
            guard !isFinished else { pair.continuation.finish(); return }
            continuations[id] = pair.continuation
            pair.continuation.yield(currentState)
        }
        return pair.stream
    }

    /// Called on the camera's session queue before configuration/startRunning.
    /// Repeated start requests must not reset an existing interruption.
    @discardableResult
    func beginObserving() -> UUID? {
        onQueue {
            guard !isFinished else { return nil }
            if let generation { return generation }
            let id: UUID = UUID()
            generation = id
            observers = [
                center.addObserver(forName: AVCaptureSession.wasInterruptedNotification,
                                   object: session, queue: nil) { [weak self] notification in
                    guard let self, let object = notification.object as AnyObject?, object === session else { return }
#if os(iOS) || os(tvOS) || os(visionOS)
                    let reason: AVCaptureSession.InterruptionReason? =
                        (notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? NSNumber)
                            .flatMap { AVCaptureSession.InterruptionReason(rawValue: $0.intValue) }
                    enqueue(.interrupted(reason: reason), generation: id)
#else
                    enqueue(.interrupted, generation: id)
#endif
                },
                center.addObserver(forName: AVCaptureSession.interruptionEndedNotification,
                                   object: session, queue: nil) { [weak self] notification in
                    guard let self, let object = notification.object as AnyObject?, object === session else { return }
                    enqueue(.notInterrupted, generation: id)
                }
            ]
            return id
        }
    }

    /// Resets interruption state without finishing subscriptions, allowing the
    /// same Camera to stop and restart. In-flight old callbacks are invalidated.
    func stopObserving() {
        onQueue {
            generation = nil
            removeObservers()
            publish(.notInterrupted)
        }
    }

    func finish() {
        onQueue {
            guard !isFinished else { return }
            isFinished = true
            generation = nil
            removeObservers()
            let activeContinuations = Array(continuations.values)
            continuations.removeAll()
            for continuation in activeContinuations { continuation.finish() }
        }
    }

    /// Shared ingress for notification callbacks; the generation check also
    /// rejects a callback already in flight when its observer was removed.
    func enqueue(_ state: State, generation expectedGeneration: UUID) {
        queue.async { [weak self] in
            guard let self, !isFinished, generation == expectedGeneration else { return }
            publish(state)
        }
    }

    private func publish(_ state: State) {
        guard !isFinished, state != currentState else { return }
        currentState = state
        for continuation in continuations.values { continuation.yield(state) }
    }

    private func removeObservers() {
        for observer in observers { center.removeObserver(observer) }
        observers.removeAll()
    }

    private func onQueue<Result>(_ body: () -> Result) -> Result {
        if DispatchQueue.getSpecific(key: queueKey) != nil { return body() }
        return queue.sync(execute: body)
    }
}
