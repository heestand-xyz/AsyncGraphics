//
//  CameraPosition.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

import AVKit

extension Graphic {
    
    public enum CameraPosition: Hashable, Sendable {
        case front
        case back
        case external
        public mutating func flip() {
            self = flipped()
        }
        public func flipped() -> CameraPosition {
            self == .front ? .back : .front
        }
        var av: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            case .back:
                return .back
            case .external:
                return .unspecified
            }
        }
    }
}
