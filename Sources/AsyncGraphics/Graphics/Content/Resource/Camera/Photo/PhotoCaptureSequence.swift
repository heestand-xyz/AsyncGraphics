//
//  PhotoCaptureSequence.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation
import os

/// Orders processed photo bytes without making cancellation end the native capture.
/// The delegate must finish the sequence only from its final capture callback.
final class PhotoCaptureSequence: Sendable {
    enum SequenceError: LocalizedError, Equatable, Sendable {
        case invalidIndex(Int)
        case duplicateIndex(Int)
        case incompleteCapture(expected: Int, received: Int)

        var errorDescription: String? {
            switch self {
            case .invalidIndex(let index):
                "The camera returned an invalid photo index (\(index)). Try capturing again."
            case .duplicateIndex(let index):
                "The camera returned photo index \(index) more than once. Try capturing again."
            case .incompleteCapture(let expected, let received):
                "The camera returned \(received) of \(expected) requested photos. Try capturing again."
            }
        }
    }

    enum Event: Sendable {
        case photo(index: Int, data: Data)
        case finished(Result<Void, any Error>)
    }

    private struct State: Sendable {
        let expectedCount: Int
        var photos: [Int: Data] = [:]
        var receivedIndices: Set<Int> = []
        var nextIndex: Int = 0
        var isFinished: Bool = false
        var isRetired: Bool = false
        var error: (any Error)?
        var continuation: CheckedContinuation<Event, Never>?

        mutating func nextEvent() -> Event? {
            if error == nil, let data: Data = photos.removeValue(forKey: nextIndex) {
                let index: Int = nextIndex
                nextIndex += 1
                return .photo(index: index, data: data)
            }
            guard isFinished else { return nil }
            if let error { return .finished(.failure(error)) }
            guard nextIndex == expectedCount else {
                return .finished(.failure(SequenceError.incompleteCapture(
                    expected: expectedCount,
                    received: receivedIndices.count
                )))
            }
            return .finished(.success(()))
        }

        mutating func delivery() -> (CheckedContinuation<Event, Never>, Event)? {
            guard let continuation, let event: Event = nextEvent() else { return nil }
            self.continuation = nil
            return (continuation, event)
        }
    }

    private let state: OSAllocatedUnfairLock<State>

    var isFinished: Bool { state.withLock { $0.isFinished } }

    init(expectedCount: Int) {
        precondition(expectedCount > 0)
        state = OSAllocatedUnfairLock(initialState: State(expectedCount: expectedCount))
    }

    func append(index: Int, data: Data) {
        let delivery: (CheckedContinuation<Event, Never>, Event)? = state.withLock { state in
            guard !state.isRetired else { return nil }
            precondition(!state.isFinished, "Photo data arrived after capture completion.")
            guard (0..<state.expectedCount).contains(index) else {
                state.error = state.error ?? SequenceError.invalidIndex(index)
                state.photos.removeAll()
                return state.delivery()
            }
            guard state.receivedIndices.insert(index).inserted else {
                state.error = state.error ?? SequenceError.duplicateIndex(index)
                state.photos.removeAll()
                return state.delivery()
            }
            if state.error == nil { state.photos[index] = data }
            return state.delivery()
        }
        if let (continuation, event) = delivery { continuation.resume(returning: event) }
    }

    func recordFailure(_ error: any Error) {
        state.withLock { state in
            guard !state.isRetired else { return }
            state.error = state.error ?? error
            state.photos.removeAll()
        }
    }

    func finish(error: (any Error)? = nil) {
        let delivery: (CheckedContinuation<Event, Never>, Event)? = state.withLock { state in
            guard !state.isRetired else { return nil }
            precondition(!state.isFinished, "Photo capture completed more than once.")
            state.isFinished = true
            state.error = state.error ?? error
            if state.error != nil { state.photos.removeAll() }
            return state.delivery()
        }
        if let (continuation, event) = delivery { continuation.resume(returning: event) }
    }

    /// Used only after the owner has synchronously stopped and detached the session.
    /// Late framework callbacks belong to the retired session and cannot publish.
    func retire(error: any Error) {
        let delivery: (CheckedContinuation<Event, Never>, Event)? = state.withLock { state in
            guard !state.isFinished else { return nil }
            state.isRetired = true
            state.isFinished = true
            state.error = error
            state.photos.removeAll()
            return state.delivery()
        }
        if let (continuation, event) = delivery { continuation.resume(returning: event) }
    }

    /// Intentionally ignores task cancellation: callers must drain through `.finished`
    /// before stopping the session or releasing exclusive camera ownership.
    func next() async -> Event {
        await withCheckedContinuation { continuation in
            let event: Event? = state.withLock { state in
                precondition(state.continuation == nil, "Photo capture has multiple consumers.")
                if let event: Event = state.nextEvent() { return event }
                state.continuation = continuation
                return nil
            }
            if let event { continuation.resume(returning: event) }
        }
    }
}
