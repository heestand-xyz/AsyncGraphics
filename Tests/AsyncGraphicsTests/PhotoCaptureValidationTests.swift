//
//  PhotoCaptureValidationTests.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation
import Testing
@testable import AsyncGraphics

@Suite("Photo Capture Validation")
struct PhotoCaptureValidationTests {
    @Test("Automatic focus ignores the supplied point, including invalid coordinates")
    func automaticFocusIgnoresSuppliedPoint() throws {
        let points: [CGPoint?] = [
            nil, .zero, CGPoint(x: 1.0, y: 1.0), CGPoint(x: -1.0, y: 2.0),
            CGPoint(x: CGFloat.nan, y: CGFloat.infinity)
        ]
        for point in points {
            #expect(try PhotoCaptureValidation.selectedFocusPoint(point, autoFocus: true) == nil)
        }
    }

    @Test("Selected-point focus preserves valid coordinates and rejects invalid coordinates")
    func selectedFocusPointRequiresNormalizedCoordinates() throws {
        let points: [CGPoint?] = [nil, .zero, CGPoint(x: 1.0, y: 1.0), CGPoint(x: 0.25, y: 0.75)]
        for point in points {
            #expect(try PhotoCaptureValidation.selectedFocusPoint(point, autoFocus: false) == point)
        }
        let invalidPoints: [CGPoint] = [
            CGPoint(x: -0.01, y: 0.5), CGPoint(x: 0.5, y: 1.01),
            CGPoint(x: CGFloat.nan, y: 0.5), CGPoint(x: 0.5, y: CGFloat.infinity)
        ]
        for point in invalidPoints {
            #expect(throws: PhotoCaptureValidation.ValidationError.invalidFocusPoint) {
                try PhotoCaptureValidation.selectedFocusPoint(point, autoFocus: false)
            }
        }
    }

    @Test("Focus points must be finite and inside the normalized picture area")
    func focusPointRequiresFiniteNormalizedCoordinates() throws {
        try PhotoCaptureValidation.focusPoint(nil)
        for point in [CGPoint.zero, CGPoint(x: 1.0, y: 1.0), CGPoint(x: 0.25, y: 0.75)] {
            try PhotoCaptureValidation.focusPoint(point)
        }
        for point in [
            CGPoint(x: -0.01, y: 0.5), CGPoint(x: 0.5, y: 1.01),
            CGPoint(x: CGFloat.nan, y: 0.5), CGPoint(x: 0.5, y: CGFloat.infinity)
        ] {
            #expect(throws: PhotoCaptureValidation.ValidationError.invalidFocusPoint) {
                try PhotoCaptureValidation.focusPoint(point)
            }
        }
    }

    @Test("Bracket capability validation rejects invalid requests without clamping")
    func bracketCapabilityValidationRejectsInvalidRequests() throws {
        try PhotoCaptureValidation.exposureOffsets([-2.0, 0.0, 2.0], maximumCount: 3, supportedRange: -2.0...2.0)
        try PhotoCaptureValidation.exposureOffsets([-1.0, -1.0, 1.0], maximumCount: 3, supportedRange: -2.0...2.0)
        #expect(throws: PhotoCaptureValidation.ValidationError.bracketedCaptureNotSupported) {
            try PhotoCaptureValidation.exposureOffsets([0.0], maximumCount: 0, supportedRange: -2.0...2.0)
        }
        #expect(throws: PhotoCaptureValidation.ValidationError.tooManyBracketedPhotos(maximum: 2)) {
            try PhotoCaptureValidation.exposureOffsets([-1.0, 0.0, 1.0], maximumCount: 2, supportedRange: -2.0...2.0)
        }
        let invalidOffsets: [[Float]] = [[], [-3.0], [3.0], [.nan], [.infinity]]
        for offsets in invalidOffsets {
            #expect(throws: PhotoCaptureValidation.ValidationError.invalidExposureOffsets) {
                try PhotoCaptureValidation.exposureOffsets(offsets, maximumCount: 3, supportedRange: -2.0...2.0)
            }
        }
    }
}
