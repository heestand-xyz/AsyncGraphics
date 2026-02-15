//
//  SendableSampleBuffer.swift
//  AsyncGraphics
//
//  Created by Anton on 2024-12-24.
//

import CoreMedia

public struct SendableSampleBuffer: @unchecked Sendable {
    
    private let sampleBuffer: CMSampleBuffer
    
    fileprivate init(sampleBuffer: CMSampleBuffer) {
        self.sampleBuffer = sampleBuffer
    }
}

extension SendableSampleBuffer {
    public func receive() -> CMSampleBuffer {
        sampleBuffer
    }
}

extension CMSampleBuffer {
    public func send() -> SendableSampleBuffer {
        SendableSampleBuffer(sampleBuffer: self)
    }
}
