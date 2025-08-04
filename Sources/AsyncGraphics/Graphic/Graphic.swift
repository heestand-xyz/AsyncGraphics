//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import SwiftUI
import CoreGraphics
@preconcurrency import Metal
import TextureMap
import PixelColor
import CoreGraphicsExtensions
import CoreImage
import CoreVideo
import CoreMedia

public struct Graphic: Graphicable, Identifiable {
    
    public let id: UUID
    
    let name: String
    
    public let texture: MTLTexture
    
    public let bits: TMBits
    public let colorSpace: TMColorSpace

#if DEBUG
    /// Quick Look Debug Active
    ///
    /// Only available with `#if DEBUG`.
    /// Default is `false`.
    /// Setting this to `true` will create an extra image for each ``Graphic`` for debug previewing.
    nonisolated(unsafe) public static var quickLookDebugActive: Bool = false
    /// Quick Look Debug Image
    ///
    /// Preview for debugging.
    /// Tap the eye icon on while in a breakpoint to see the preview.
    private var quickLookDebugImage: CGImage?
#endif
    
    init(id: UUID = UUID(), name: String, texture: MTLTexture, bits: TMBits, colorSpace: TMColorSpace) {
        self.id = id
        self.name = name
        self.texture = texture
        self.bits = bits
        self.colorSpace = colorSpace
#if DEBUG
        if Self.quickLookDebugActive {
            quickLookDebugImage = try? TextureMap.cgImage(
                texture: texture,
                colorSpace: colorSpace,
                bits: bits
            )
        }
#endif
    }
}

// MARK: - Resolution

extension Graphic {
    
    public var resolution: CGSize {
        texture.size
    }
    
    public var width: CGFloat {
        resolution.width
    }
    
    public var height: CGFloat {
        resolution.height
    }
}

// MARK: - Image

extension Graphic {
    
    enum ImageDataError: LocalizedError {
        
        case pngDataNotFound
        case mappingFailed
        
        var errorDescription: String? {
            switch self {
            case .pngDataNotFound:
                return "AsyncGraphics - Image - PNG Data Not Found"
            case .mappingFailed:
                return "AsyncGraphics - Image - Mapping Failed"
            }
        }
    }
    
    /// UIImage / NSImage
    public var image: TMImage {
        get async throws {
            try await mirroredVertically().texture.image(colorSpace: colorSpace, bits: bits)
        }
    }
    
    /// Sendable wrapped UIImage / NSImage.
    ///
    /// Get the image by calling `.receive()`
    public var sendableImage: SendableImage {
        get async throws {
            try await image.send()
        }
    }
    
    /// UIImage / NSImage
    ///
    /// Raw image is just using an alternative way of converting the graphic to an image. It is faster than ``image``. Only for 8 bit graphics.
    public var rawImage: TMImage {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                do {
                    let cgImage = try TextureMap.copyCGImage(texture: texture)
                    let image = TMImage(cgImage: cgImage, size: resolution)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// SwiftUI Image
    public var imageForSwiftUI: Image {
        get async throws {
            Image(tmImage: try await image)
        }
    }
    
    public var cgImage: CGImage {
        get async throws {
            try await TextureMap.cgImage(texture: mirroredVertically().texture, colorSpace: colorSpace, bits: bits)
        }
    }
    
    public var ciImage: CIImage {
        get throws {
            try TextureMap.ciImage(texture: texture, colorSpace: colorSpace)
        }
    }
    
    /// UIImage / NSImage
    public var pngData: Data {
        get async throws {
            guard let pngData =  try await image.pngData()
            else { throw ImageDataError.pngDataNotFound }
            return pngData
        }
    }
    
    /// UIImage / NSImage with better support for saving as a transparent png file.
    public var imageWithTransparency: TMImage {
        get async throws {
            guard let image = TMImage(data: try await pngData)
            else { throw ImageDataError.mappingFailed }
            return image
        }
    }
    
    /// Sendable wrapped UIImage / NSImage with trasparency.
    ///
    /// Get the image by calling `.receive()`
    public var sendableImageWithTransparency: SendableImage {
        get async throws {
            try await imageWithTransparency.send()
        }
    }
    
    public func writeImage(to url: URL, xdr: Bool = false) async throws {
        let image: TMImage = try await image
        try TextureMap.write(image: image, to: url, bits: bits, colorSpace: xdr ? .xdr : colorSpace)
    }
    
    /// XDR UIImage / NSImage
    /// (Use with 16 or 32 bit graphics)
    public var xdrImage: TMImage {
        get async throws {
            try await assignColorSpace(.xdr).image
        }
    }
    
    /// Sendable wrapped XDR UIImage / NSImage.
    /// (Use with 16 or 32 bit graphics)
    /// 
    /// Get the image by calling `.receive()`
    public var sendableXDRImage: SendableImage {
        get async throws {
            try await xdrImage.send()
        }
    }
}

// MARK: - Buffer

extension Graphic {
    
    public var pixelBuffer: CVPixelBuffer {
        get throws {
            try TextureMap.pixelBuffer(texture: texture)
        }
    }
    
    public var sampleBuffer: CMSampleBuffer {
        get async throws {
            let graphic: Graphic = try await mirroredVertically()
            return try TextureMap.sampleBuffer(texture: graphic.texture, colorSpace: colorSpace)
        }
    }
}

// MARK: - Pixels

extension Graphic {
    
    enum PixelError: LocalizedError {
        
        case noChannelsFound
        case badChannelCount

        var errorDescription: String? {
            switch self {
            case .noChannelsFound:
                return "AsyncGraphics - Pixels - No Channels Found"
            case .badChannelCount:
                return "AsyncGraphics - Pixels - Bad Channel Count"
            }
        }
    }
    
    public var firstPixelColor: PixelColor {

        get async throws {
            
            let channels: [CGFloat] = try await channels
            
            guard !channels.isEmpty, channels.count >= 4 else {
                throw PixelError.noChannelsFound
            }
            
            return PixelColor(red: channels[0],
                              green: channels[1],
                              blue: channels[2],
                              opacity: channels[3])
        }
    }
    
    public var averagePixelColor: PixelColor {
        get async throws {
            try await reduce(by: .average)
        }
    }
    
    /// An array of rows of colors.
    public var pixelColors: [[PixelColor]] {
        
        get async throws {
            
            let channels: [CGFloat] = try await channels
            
            guard !channels.isEmpty else {
                throw PixelError.noChannelsFound
            }
            
            let count = Int(resolution.width) * Int(resolution.height) * 4
            guard channels.count == count else {
                throw PixelError.badChannelCount
            }
            
            var pixelColors: [[PixelColor]] = []
            
            for y in 0..<Int(resolution.height) {
            
                var rows: [PixelColor] = []
                
                for x in 0..<Int(resolution.width) {
            
                    let index = y * Int(resolution.width) * 4 + x * 4
                    
                    let red = channels[index]
                    let green = channels[index + 1]
                    let blue = channels[index + 2]
                    let alpha = channels[index + 3]
                    
                    let color = PixelColor(red: red,
                                           green: green,
                                           blue: blue,
                                           opacity: alpha)
                    
                    rows.append(color)
                }
                
                pixelColors.append(rows)
            }
            
            return pixelColors
        }
    }
    
    /// Normalized channels
    public var channels: [CGFloat] {
        
        get async throws {
            
            try await TextureMap.rawNormalized(texture: texture, bits: bits)
        }
    }
    
    /// 8 bit
    public var channels8: [UInt8] {
        
        get async throws {
            try await TextureMap.raw8(texture: withBits(.bit8).texture)
        }
    }
    
    #if !os(macOS)
    /// 16 bit
    public var channels16: [Float16] {
        
        get throws {
            try TextureMap.raw16(texture: texture)
        }
    }
    #endif
    
    /// 32 bit
    public var channels32: [Float] {
        
        get throws {
            try TextureMap.raw32(texture: texture)
        }
    }
}

// MARK: - Empty

extension Graphic {
    
    public static func empty() throws -> Graphic {
        let pixel: [UInt8] = [0,0,0,0]
        let texture: MTLTexture = try TextureMap.texture(channels: pixel, resolution: CGSize(width: 1, height: 1), on: Renderer.metalDevice)
        return Graphic(name: "Empty", texture: texture, bits: ._8, colorSpace: .sRGB)
    }
}

// MARK: - Equatable

extension Graphic: Equatable {
    
    public static func == (lhs: Graphic, rhs: Graphic) -> Bool {
        lhs.id == rhs.id
    }
}

@available(iOS 14.0, tvOS 14, macOS 11, *)
extension Graphic {
    
    public func isPixelsEqual(to graphic: Graphic, threshold: CGFloat = 0.000_1) async throws -> Bool {
        
        guard resolution == graphic.resolution else {
            return false
        }
        
        let difference = try await blended(with: graphic, blendingMode: .difference, placement: .stretch)
        
        let color = try await difference.averagePixelColor
                
        return color.brightness <= threshold
    }
}
