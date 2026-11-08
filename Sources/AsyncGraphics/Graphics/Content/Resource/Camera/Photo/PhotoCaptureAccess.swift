//
//  PhotoCaptureAccess.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation

/// A photo transaction keeps this lease through native completion and cleanup.
/// Live-camera handoff remains the caller's responsibility.
actor PhotoCaptureAccess {
    enum AccessError: Error, Sendable {
        case alreadyCapturing
    }

    static let shared: PhotoCaptureAccess = PhotoCaptureAccess()
    private var lease: UUID?

    func acquire() throws(AccessError) -> UUID {
        guard lease == nil else { throw .alreadyCapturing }
        let lease: UUID = UUID()
        self.lease = lease
        return lease
    }

    func release(_ lease: UUID) {
        precondition(self.lease == lease, "Photo capture released an invalid lease.")
        self.lease = nil
    }
}
