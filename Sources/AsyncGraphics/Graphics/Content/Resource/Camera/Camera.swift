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
                        func mirrored(graphic: Graphic) async -> Graphic? {
                            try? await graphic.mirroredHorizontally()
                        }
                        func rotated(graphic: Graphic) async -> Graphic? {
                            let newOrientation = await UIDevice.current.orientation
                            if newOrientation != cameraController.currentOrientation {
                                var verticalOrientations: [UIDeviceOrientation] = [
                                    .portrait, .landscapeLeft, .landscapeRight
                                ]
                                #if os(iOS)
                                if await UIDevice.current.userInterfaceIdiom == .pad {
                                    verticalOrientations.append(.portraitUpsideDown)
                                }
                                #endif
                                if verticalOrientations.contains(newOrientation) {
                                    cameraController.currentOrientation = newOrientation
                                }
                            }
                            switch cameraController.currentOrientation {
                            case .portrait:
                                return try? await graphic.rotatedLeft()
                            case .portraitUpsideDown:
                                return try? await graphic.rotatedRight()
                            case .landscapeLeft:
                                return try? await graphic.rotated(.degrees(180))
                            case .landscapeRight:
                                return graphic
                            default:
                                #if os(iOS)
                                return try? await graphic.rotatedLeft()
                                #else
                                return try? await graphic
                                #endif
                            }
                        }
                        let graphic: Graphic = await rotated(graphic: mirrored(graphic: graphic) ?? graphic) ?? graphic
                        continuation.resume(returning: graphic)
                    }
                }
            }
        }, onCancel: {
            cameraController.cancel()
        })
    }
}
