//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
    /// Async stream of a live camera feed
    public static func camera(_ position: AVCaptureDevice.Position,
                              device: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              preset: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let cameraController = try CameraController(deviceType: device, position: position, preset: preset)
        
        return AsyncStream<Graphic>.init(unfolding: {
            
            await withCheckedContinuation { continuation in
                
                cameraController.cameraFrameHandler = { graphic in
                    
                    cameraController.cameraFrameHandler = nil
                    
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
