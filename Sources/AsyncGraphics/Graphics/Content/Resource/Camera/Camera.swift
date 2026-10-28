//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
#if !os(visionOS)
    /// Async live stream from the camera
    public static func camera(device: AVCaptureDevice,
                              quality: AVCaptureSession.Preset = .high) async throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(device: device, quality: quality)
        
        return try await self.camera(with: camera)
    }

    /// Async live stream from the camera with preview-sized output buffers.
    public static func camera(device: AVCaptureDevice,
                              quality: AVCaptureSession.Preset = .high,
                              previewSized: Bool) async throws -> AsyncStream<Graphic> {

        let camera = try Camera(
            device: device,
            quality: quality,
            previewSized: previewSized
        )

        return try await self.camera(with: camera)
    }
    
    /// Async live stream from the camera
    public static func camera(at position: CameraPosition = .front,
                              lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              quality: AVCaptureSession.Preset = .high) async throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(position.av, with: lens, quality: quality, external: position == .external)
        
        return try await self.camera(with: camera)
    }

    /// Async live stream from the camera with preview-sized output buffers.
    public static func camera(at position: CameraPosition = .front,
                              lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              quality: AVCaptureSession.Preset = .high,
                              previewSized: Bool) async throws -> AsyncStream<Graphic> {

        let camera = try Camera(
            position.av,
            with: lens,
            quality: quality,
            external: position == .external,
            previewSized: previewSized
        )

        return try await self.camera(with: camera)
    }
#endif
    
    /// Async live stream from the camera
    public static func camera(with camera: Camera) async throws(Camera.CameraError) -> AsyncStream<Graphic> {
        try await camera.start()
        return AsyncStream<Graphic> {
            guard !Task.isCancelled,
                  var graphic = await camera.nextGraphic()
            else { return nil }
            do {
                graphic = try await rotated(
                    graphic: graphic,
                    with: camera
                )
                guard !Task.isCancelled else { return nil }
                graphic = try await mirrored(
                    graphic: graphic,
                    at: camera.position
                )
            } catch {
                print("AsyncGraphics - Failed to orient camera graphic: \(error)")
            }
            guard !Task.isCancelled else { return nil }
            return graphic
        } onCancel: {
            camera.stopWithoutWaiting()
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
    
    static func rotated(graphic: Graphic, with camera: Camera) async throws -> Graphic {
#if os(iOS)
        let orientation: UIInterfaceOrientation? = await MainActor.run {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let scene = scenes.first { $0.activationState == .foregroundActive && $0.keyWindow != nil }
                ?? scenes.first { $0.activationState == .foregroundActive }
            return scene?.effectiveGeometry.interfaceOrientation
        }
        guard let orientation else { return graphic }
#if !targetEnvironment(macCatalyst)
        if #available(iOS 27.0, *),
           let captureOrientation = CameraOrientation.captureOrientation(for: orientation) {
            // These are raw pixel buffers, not an AVCaptureVideoPreviewLayer. The
            // device-relative angle accounts for the active camera's sensor mounting.
            let angle = await camera.rotationAngle(relativeTo: captureOrientation)
            return try await graphic.rotatedCamera(angle: angle)
        }
#endif
        let position = camera.position
        switch orientation {
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

#if os(iOS)
// MARK: - Camera Orientation

/// Interface and physical device orientations use opposite landscape conventions.
enum CameraOrientation {
    static func captureOrientation(for orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        switch orientation {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        case .landscapeLeft: .landscapeLeft
        case .landscapeRight: .landscapeRight
        default: nil
        }
    }

    static func captureOrientation(for orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch orientation {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        case .landscapeLeft: .landscapeRight
        case .landscapeRight: .landscapeLeft
        default: nil
        }
    }
}

#endif

// MARK: - Sensor Rotation

extension Graphic {
    /// Device-relative orientations are quarter turns. Transpose swaps dimensions
    /// for 90/270 degrees; the general transform operation retains the canvas size.
    func rotatedCamera(angle: CGFloat) async throws -> Graphic {
        switch angle {
        case 0: return self
        case 90: return try await rotatedRight()
        case 180: return try await mirroredHorizontally().mirroredVertically()
        case 270: return try await rotatedLeft()
        default: throw CameraRotationError.unsupportedAngle(angle)
        }
    }
}

enum CameraRotationError: Error {
    case unsupportedAngle(CGFloat)
}
