//
//  SendablePixelBuffer.swift
//  AsyncGraphics
//
//  Created by Anton on 2024-12-24.
//

import Vision

public struct SendablePixelBuffer: @unchecked Sendable {
    
    private let pixelBuffer: CVPixelBuffer
    
    fileprivate init(pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
    }
}

extension SendablePixelBuffer {
    public func receive() -> CVPixelBuffer {
        pixelBuffer
    }
}

extension CVPixelBuffer {
    public func send() -> SendablePixelBuffer {
        SendablePixelBuffer(pixelBuffer: self)
    }
}
