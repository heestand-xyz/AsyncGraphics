//
//  PhotoCaptureDelegate.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS)
import Foundation
import AVFoundation

final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let sequence: PhotoCaptureSequence
    private let isBracketed: Bool

    init(sequence: PhotoCaptureSequence, isBracketed: Bool) {
        self.sequence = sequence
        self.isBracketed = isBracketed
        super.init()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error {
            sequence.recordFailure(error)
            return
        }
        guard let data: Data = photo.fileDataRepresentation() else {
            sequence.recordFailure(Graphic.PhotoCamera.PhotoCameraError.noImageCapture)
            return
        }
        // sequenceCount is one-based for a bracket and zero for a single photo.
        let index: Int = isBracketed ? photo.sequenceCount - 1 : 0
        sequence.append(index: index, data: data)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: (any Error)?) {
        sequence.finish(error: error)
    }
}
#endif
