//
//  PhotoCaptureAccessTests.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation
import Testing
@testable import AsyncGraphics

@Suite("Photo Capture Access")
struct PhotoCaptureAccessTests {
    @Test("Concurrent photo requests remain exclusive until the owner releases")
    func photoAccessRemainsExclusiveUntilRelease() async throws {
        let access: PhotoCaptureAccess = PhotoCaptureAccess()
        let leases: [UUID] = await withTaskGroup(of: UUID?.self) { group in
            for _ in 0..<24 {
                group.addTask {
                    do { return try await access.acquire() }
                    catch { return nil }
                }
            }
            var leases: [UUID] = []
            for await lease in group {
                if let lease { leases.append(lease) }
            }
            return leases
        }
        #expect(leases.count == 1)
        let first: UUID = try #require(leases.first)
        await access.release(first)
        let second: UUID = try await access.acquire()
        #expect(first != second)
        await access.release(second)
    }
}
