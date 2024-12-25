//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
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
    
#if !os(visionOS)
    /// Async live stream from the camera
    public static func camera(device: AVCaptureDevice,
                              quality: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(device: device, quality: quality)
        
        return self.camera(with: camera)
    }
    
    /// Async live stream from the camera
    public static func camera(at position: CameraPosition,
                              lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              quality: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(position.av, with: lens, quality: quality, external: position == .external)
        
        return self.camera(with: camera)
    }
#endif
    
    /// Async live stream from the camera
    public static func camera(with camera: Camera) -> AsyncStream<Graphic> {
        
        camera.start()
        
        return AsyncStream<Graphic>(unfolding: {
            
            await withCheckedContinuation { continuation in
                
                Task { @MainActor in
                    
                    camera.graphicsHandler = { graphic in
                        
                        camera.graphicsHandler = nil
                        
                        Task {
                            func mirrored(graphic: Graphic) async -> Graphic {
#if os(macOS)
                                return (try? await graphic.mirroredHorizontally()) ?? graphic
#else
                                if camera.position == .front {
                                    return (try? await graphic.mirroredHorizontally()) ?? graphic
                                }
                                return graphic
#endif
                            }
                            func rotated(graphic: Graphic) async -> Graphic {
#if os(iOS)
                                guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
                                else { return graphic }
                                return await {
                                    switch await windowScene.interfaceOrientation {
                                    case .portrait:
                                        return try? await graphic.rotatedRight()
                                    case .portraitUpsideDown:
                                        return try? await graphic.rotatedLeft()
                                    case .landscapeLeft:
                                        switch camera.position {
                                        case .back:
                                            return try? await graphic.rotated(.degrees(180))
                                        default:
                                            return nil
                                        }
                                    case .landscapeRight:
                                        switch camera.position {
                                        case .front:
                                            return try? await graphic.rotated(.degrees(180))
                                        default:
                                            return nil
                                        }
                                    default:
                                        return nil
                                    }
                                }() ?? graphic
#else
                                return graphic
#endif
                            }
                            let graphic: Graphic = await mirrored(graphic: rotated(graphic: graphic))
                            continuation.resume(returning: graphic)
                        }
                    }
                }
            }
        }, onCancel: {
            camera.stop()
        })
    }
}
