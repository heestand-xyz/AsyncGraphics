//
//  PhotoCameraExecutor.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Dispatch

/// Blocking AVFoundation session operations run on a dedicated serial queue.
final class PhotoCameraExecutor: SerialExecutor {
    private let queue: DispatchQueue = DispatchQueue(label: "async-graphics.photo-camera.session")

    func enqueue(_ job: consuming ExecutorJob) {
        let job: UnownedJob = UnownedJob(job)
        let executor: UnownedSerialExecutor = asUnownedSerialExecutor()
        queue.async {
            job.runSynchronously(on: executor)
        }
    }
}
