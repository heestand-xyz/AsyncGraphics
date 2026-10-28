import CoreGraphics
import PixelColor
import Testing
@testable import AsyncGraphics
#if os(iOS)
import AVFoundation
import UIKit
#endif

@Suite("Camera Orientation", .serialized)
struct CameraOrientationTests {

    @Test("Sensor rotations preserve every pixel and swap dimensions for quarter turns",
          arguments: [0.0, 90.0, 180.0, 270.0])
    func sensorRotation(angle: Double) async throws {
        let cyan = PixelColor(red: 0, green: 1, blue: 1)
        let magenta = PixelColor(red: 1, green: 0, blue: 1)
        let yellow = PixelColor(red: 1, green: 1, blue: 0)
        let source: [[PixelColor]] = [[.red, .green, .blue], [cyan, magenta, yellow]]
        let graphic = try Graphic.pixels(source)
        let result = try await graphic.rotatedCamera(angle: angle)
        let expected: [[PixelColor]]
        switch angle {
        case 90: expected = [[cyan, .red], [magenta, .green], [yellow, .blue]]
        case 180: expected = [[yellow, magenta, cyan], [.blue, .green, .red]]
        case 270: expected = [[.blue, yellow], [.green, magenta], [.red, cyan]]
        default: expected = source
        }
        #expect(result.resolution == CGSize(width: expected[0].count, height: expected.count))
        #expect(try result.pixelColors == expected)

        // A front preview mirrors in display space, after sensor rotation.
        let frontPreview = try await result.mirroredHorizontally()
        #expect(try frontPreview.pixelColors == expected.map { Array($0.reversed()) })
    }

#if os(iOS)
    @Test("Physical and interface landscape conventions map to capture orientation")
    func landscapeConventions() {
        #expect(CameraOrientation.captureOrientation(for: UIInterfaceOrientation.landscapeLeft) == .landscapeLeft)
        #expect(CameraOrientation.captureOrientation(for: UIInterfaceOrientation.landscapeRight) == .landscapeRight)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.landscapeLeft) == .landscapeRight)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.landscapeRight) == .landscapeLeft)
        #expect(CameraOrientation.captureOrientation(for: UIInterfaceOrientation.portrait) == .portrait)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.portrait) == .portrait)
        #expect(CameraOrientation.captureOrientation(for: UIInterfaceOrientation.portraitUpsideDown) == .portraitUpsideDown)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.portraitUpsideDown) == .portraitUpsideDown)
        #expect(CameraOrientation.captureOrientation(for: UIInterfaceOrientation.unknown) == nil)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.unknown) == nil)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.faceUp) == nil)
        #expect(CameraOrientation.captureOrientation(for: UIDeviceOrientation.faceDown) == nil)
    }
#endif
}
