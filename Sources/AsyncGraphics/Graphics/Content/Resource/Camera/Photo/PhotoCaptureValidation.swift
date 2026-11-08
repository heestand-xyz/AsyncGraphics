//
//  PhotoCaptureValidation.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation

enum PhotoCaptureValidation {
    enum ValidationError: Error, Equatable, Sendable {
        case invalidFocusPoint
        case invalidExposureOffsets
        case bracketedCaptureNotSupported
        case tooManyBracketedPhotos(maximum: Int)
    }

    static func selectedFocusPoint(_ point: CGPoint?, autoFocus: Bool) throws(ValidationError) -> CGPoint? {
        guard !autoFocus else { return nil }
        try focusPoint(point)
        return point
    }

    static func focusPoint(_ point: CGPoint?) throws(ValidationError) {
        guard let point else { return }
        guard point.x.isFinite, point.y.isFinite,
              (0.0...1.0).contains(point.x), (0.0...1.0).contains(point.y) else {
            throw .invalidFocusPoint
        }
    }

    static func exposureOffsets(
        _ offsets: [Float],
        maximumCount: Int,
        supportedRange: ClosedRange<Float>
    ) throws(ValidationError) {
        guard maximumCount > 0 else { throw .bracketedCaptureNotSupported }
        guard !offsets.isEmpty,
              offsets.allSatisfy({ $0.isFinite && supportedRange.contains($0) }) else {
            throw .invalidExposureOffsets
        }
        guard offsets.count <= maximumCount else { throw .tooManyBracketedPhotos(maximum: maximumCount) }
    }
}
