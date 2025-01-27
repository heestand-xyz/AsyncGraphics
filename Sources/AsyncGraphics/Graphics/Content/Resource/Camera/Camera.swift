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
    public static func camera(at position: CameraPosition = .front,
                              lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              quality: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(position.av, with: lens, quality: quality, external: position == .external)
        
        return self.camera(with: camera)
    }
#endif
    
    /// Async live stream from the camera
    public static func camera(with camera: Camera) -> AsyncStream<Graphic> {
        camera.start()
        return AsyncStream<Graphic> {
            await withCheckedContinuation { continuation in
                Task { @MainActor in
                    camera.graphicsHandler = { graphic in
                        camera.graphicsHandler = nil
                        Task {
                            var graphic: Graphic = graphic
                            do {
                                graphic = try await rotated(
                                    graphic: graphic,
                                    at: camera.position
                                )
                                graphic = try await mirrored(
                                    graphic: graphic,
                                    at: camera.position
                                )
                            } catch {
                                print("AsyncGraphics - Failed to orient camera graphic: \(error)")
                            }
                            continuation.resume(returning: graphic)
                        }
                    }
                }
            }
        } onCancel: {
            camera.stop()
        }
    }
}

private extension Graphic {
    
    static func mirrored(graphic: Graphic, at position: AVCaptureDevice.Position) async throws -> Graphic {
#if os(macOS)
        return try await graphic.mirroredHorizontally()
#else
        if position == .front {
            return try await graphic.mirroredHorizontally()
        }
        return graphic
#endif
    }
    
    static func rotated(graphic: Graphic, at position: AVCaptureDevice.Position) async throws -> Graphic {
#if os(iOS)
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return graphic }
        switch await windowScene.interfaceOrientation {
        case .portrait:
            return try await graphic.rotatedRight()
        case .portraitUpsideDown:
            return try await graphic.rotatedLeft()
        case .landscapeLeft:
            switch position {
            case .back:
                return try await graphic.rotated(.degrees(180))
            default:
                return graphic
            }
        case .landscapeRight:
            switch position {
            case .front:
                return try await graphic.rotated(.degrees(180))
            default:
                return graphic
            }
        default:
            return graphic
        }
#else
        return graphic
#endif
    }
}
