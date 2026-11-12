#if os(iOS) || os(macOS)
import AVFoundation
import Foundation
import ImageIO
import PixelColor
import Testing
import UniformTypeIdentifiers
@testable import AsyncGraphics

@Suite("Photo Camera Mirroring", .serialized)
struct PhotoCameraMirroringTests {

    @Test("Front photos mirror X after decoding; rear and external photos stay unchanged",
          arguments: [false, true], [1, 3, 6, 8])
    func mirrorsFrontPhoto(preserveHDR: Bool, orientation: Int) async throws {
        let source = try Graphic.pixels([
            [PixelColor.red, .green, .blue],
            [PixelColor.white, .black, PixelColor(red: 1, green: 1, blue: 0)]
        ])
        let png = try await source.pngData
        let imageSource = try #require(CGImageSourceCreateWithData(png as CFData, nil))
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(data, UTType.tiff.identifier as CFString, 1, nil))
        CGImageDestinationAddImageFromSource(destination, imageSource, 0, [
            kCGImagePropertyOrientation: orientation
        ] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))

        let camera = Graphic.PhotoCamera()
        let back = try await camera.decodePhoto(data as Data, preserveHDR: preserveHDR, position: .back)
        let front = try await camera.decodePhoto(data as Data, preserveHDR: preserveHDR, position: .front)
        let external = try await camera.decodePhoto(data as Data, preserveHDR: preserveHDR, position: .unspecified)
        let backPixels = try await back.pixelColors
        let frontPixels = try await front.pixelColors
        #expect(frontPixels == backPixels.map { Array($0.reversed()) })
        #expect(frontPixels != backPixels)
        #expect(try await external.pixelColors == backPixels)
        #expect(front.resolution == back.resolution)
        #expect(front.bits == back.bits)
        #expect(front.colorSpace == back.colorSpace)
        if preserveHDR {
            #expect(front.bits == ._16)
            #expect(front.colorSpace == .linearDisplayP3)
        }
    }

    @Test("Invalid front-camera data still reports a decode error", arguments: [false, true])
    func invalidPhoto(preserveHDR: Bool) async {
        let camera = Graphic.PhotoCamera()
        await #expect(throws: Graphic.PhotoCamera.PhotoCameraError.self) {
            _ = try await camera.decodePhoto(Data(), preserveHDR: preserveHDR, position: .front)
        }
    }
}
#endif
