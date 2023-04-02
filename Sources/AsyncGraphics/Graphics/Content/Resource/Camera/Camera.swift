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
                            if position == .front {
                                return try? await graphic.mirroredHorizontally()
                            }
                            return nil
                        }
                        func rotated(graphic: Graphic) async -> Graphic? {
                            #if os(iOS)
                            var keyWindow: UIWindow?
                            for window in await UIApplication.shared.windows {
                                if await window.isKeyWindow {
                                    keyWindow = window
                                }
                            }
                            guard let windowScene = await keyWindow?.windowScene
                            else { return graphic }
                            switch await windowScene.interfaceOrientation {
                            case .portrait:
                                return try? await graphic.rotatedRight()
                            case .portraitUpsideDown:
                                return try? await graphic.rotatedLeft()
                            case .landscapeLeft:
                                return try? await graphic.rotated(.degrees(180))
                            case .landscapeRight:
                                return nil
                            default:
                                return nil
                            }
                            #else
                            return nil
                            #endif
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
