//
//  SendablePixelBuffer.swift
//  AsyncGraphics
//
//  Created by Anton on 2024-12-24.
//

import Vision

struct SendablePixelBuffer: @unchecked Sendable {
    
    private let pixelBuffer: CVPixelBuffer
    
    fileprivate init(pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
    }
}

extension SendablePixelBuffer {
    func receive() -> CVPixelBuffer {
        pixelBuffer
    }
}

extension CVPixelBuffer {
    func send() -> SendablePixelBuffer {
        SendablePixelBuffer(pixelBuffer: self)
    }
}
