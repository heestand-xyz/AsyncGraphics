//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
    public enum CameraPosition: Hashable {
        case front
        case back
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
            }
        }
    }
    
    /// Async live stream from the camera
    public static func camera(_ position: CameraPosition,
                              device: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              preset: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let cameraController = try CameraController(deviceType: device, position: position.av, preset: preset)
        
        return AsyncStream<Graphic>(unfolding: {
            
            await withCheckedContinuation { continuation in
                
                cameraController.graphicsHandler = { graphic in
                    
                    cameraController.graphicsHandler = nil
                    
                    Task {
                        guard let graphic: Graphic = position == .front ? try? await graphic.mirroredHorizontally() : graphic else { return }
                        
                        continuation.resume(returning: graphic)
                    }
                }
            }
        }, onCancel: {
            cameraController.cancel()
        })
    }
}
