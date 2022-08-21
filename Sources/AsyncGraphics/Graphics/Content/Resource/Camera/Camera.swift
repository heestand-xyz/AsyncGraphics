//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
    /// Async live stream from the camera
    public static func camera(_ position: AVCaptureDevice.Position,
                              device: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              preset: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let cameraController = try CameraController(deviceType: device, position: position, preset: preset)
        
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
