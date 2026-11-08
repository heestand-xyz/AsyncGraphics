//
//  PhotoCaptureSequenceTests.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation
import Testing
@testable import AsyncGraphics

@Suite("Photo Capture Sequence")
struct PhotoCaptureSequenceTests {
    enum CaptureError: Error, Equatable {
        case failed
        case timedOut
    }

    // MARK: - Tests

    @Test("Photos publish progressively in exposure order despite reordered callbacks")
    func progressiveDeliveryPreservesExposureOrder() async throws {
        let sequence: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 3)
        sequence.append(index: 2, data: Data([2]))
        sequence.append(index: 0, data: Data([0]))
        try assertPhoto(await sequence.next(), index: 0, data: Data([0]))
        #expect(!sequence.isFinished)
        sequence.append(index: 1, data: Data([1]))
        try assertPhoto(await sequence.next(), index: 1, data: Data([1]))
        try assertPhoto(await sequence.next(), index: 2, data: Data([2]))
        sequence.finish()
        try assertSuccess(await sequence.next())
    }

    @Test("Invalid, repeated, and missing exposure ordinals fail explicitly")
    func invalidOrMissingOrdinalsFail() async {
        for index in [-1, 3] {
            let sequence: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 3)
            sequence.append(index: index, data: Data([0]))
            sequence.finish()
            #expect(await failure(sequence) as? PhotoCaptureSequence.SequenceError == .invalidIndex(index))
        }

        let duplicate: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 2)
        duplicate.append(index: 0, data: Data([0]))
        duplicate.append(index: 0, data: Data([1]))
        duplicate.finish()
        #expect(await failure(duplicate) as? PhotoCaptureSequence.SequenceError == .duplicateIndex(0))

        let missing: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 3)
        missing.append(index: 1, data: Data([1]))
        missing.finish()
        #expect(await failure(missing) as? PhotoCaptureSequence.SequenceError == .incompleteCapture(expected: 3, received: 1))
    }

    @Test("Cancelling the consumer still drains native completion")
    func cancelledConsumerWaitsForNativeCompletion() async throws {
        let sequence: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 1)
        let received: (stream: AsyncStream<Void>, continuation: AsyncStream<Void>.Continuation) = AsyncStream.makeStream()
        let consumer: Task<Int, any Error> = Task(name: "PhotoCaptureSequenceTests: Drain Cancelled Capture") {
            var count: Int = 0
            while true {
                switch await sequence.next() {
                case .photo:
                    count += 1
                    received.continuation.yield(())
                case .finished(let result):
                    try result.get()
                    return count
                }
            }
        }
        consumer.cancel()
        sequence.append(index: 0, data: Data([0]))
        var iterator: AsyncStream<Void>.Iterator = received.stream.makeAsyncIterator()
        _ = await iterator.next()
        #expect(!sequence.isFinished)
        sequence.finish()
        #expect(try await consumer.value == 1)
        received.continuation.finish()
    }

    @Test("Retired captures cannot publish or resume again from late callbacks")
    func retirementRejectsLateCallbacks() async {
        let sequence: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 2)
        sequence.append(index: 1, data: Data([1]))
        sequence.retire(error: CaptureError.timedOut)
        sequence.append(index: 0, data: Data([0]))
        sequence.recordFailure(CaptureError.failed)
        sequence.finish()
        #expect(await failure(sequence) as? CaptureError == .timedOut)

        let completed: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 1)
        completed.append(index: 0, data: Data([0]))
        completed.finish()
        completed.retire(error: CaptureError.timedOut)
        #expect(await failure(completed) == nil)
    }

    @Test("A native error preserves earlier deliveries and rejects incomplete success")
    func nativeFailureAfterPartialDelivery() async throws {
        let sequence: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: 3)
        sequence.append(index: 0, data: Data([0]))
        try assertPhoto(await sequence.next(), index: 0, data: Data([0]))
        sequence.append(index: 2, data: Data([2]))
        sequence.recordFailure(CaptureError.failed)
        #expect(!sequence.isFinished)
        sequence.finish()
        #expect(await failure(sequence) as? CaptureError == .failed)
    }

    // MARK: - Helpers

    private func assertPhoto(_ event: PhotoCaptureSequence.Event, index: Int, data: Data) throws {
        guard case .photo(let actualIndex, let actualData) = event else {
            Issue.record("Expected a progressive photo.")
            throw CaptureError.failed
        }
        #expect(actualIndex == index)
        #expect(actualData == data)
    }

    private func assertSuccess(_ event: PhotoCaptureSequence.Event) throws {
        guard case .finished(let result) = event else {
            Issue.record("Expected native capture completion.")
            throw CaptureError.failed
        }
        try result.get()
    }

    private func failure(_ sequence: PhotoCaptureSequence) async -> (any Error)? {
        while true {
            switch await sequence.next() {
            case .photo: continue
            case .finished(.success): return nil
            case .finished(.failure(let error)): return error
            }
        }
    }
}
