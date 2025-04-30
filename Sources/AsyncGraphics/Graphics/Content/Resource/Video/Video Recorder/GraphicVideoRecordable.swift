//
//  GraphicVideoRecordable.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-04-30.
//

import Foundation

public protocol GraphicVideoRecordable: Sendable, Actor {
    var recording: Bool { get }
    func start() throws
    func stop() async throws -> Data
    func stop() async throws -> URL
    func cancel()
}
