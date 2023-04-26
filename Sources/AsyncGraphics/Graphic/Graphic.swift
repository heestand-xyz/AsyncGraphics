//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
import Metal
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
    
    init(id: UUID = UUID(), name: String, texture: MTLTexture, bits: TMBits, colorSpace: TMColorSpace) {
        self.id = id
        self.name = name
        self.texture = texture
        self.bits = bits
        self.colorSpace = colorSpace
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
    
    public var cgImage: CGImage {
        get throws {
            try TextureMap.cgImage(texture: texture, colorSpace: colorSpace, bits: bits)
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
}

// MARK: - Buffer

extension Graphic {
    
    public var pixelBuffer: CVPixelBuffer {
        get throws {
            try TextureMap.pixelBuffer(texture: texture, colorSpace: colorSpace)
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
                              alpha: channels[3])
        }
    }
    
    public var averagePixelColor: PixelColor {
        
        get async throws {
            
            let pixelColors: [PixelColor] = try await pixelColors.flatMap { $0 }
            
            let color: PixelColor = pixelColors.reduce(.clear, +) / CGFloat(pixelColors.count)
            
            return color
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
                                           alpha: alpha)
                    
                    rows.append(color)
                }
                
                pixelColors.append(rows)
            }
            
            return pixelColors
        }
    }
    
    public var channels: [CGFloat] {
        
        get async throws {
            
            try await TextureMap.rawNormalized(texture: texture, bits: bits)
        }
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
    
    public func isPixelsEqual(to graphic: Graphic) async throws -> Bool {
        
        guard resolution == graphic.resolution else {
            return false
        }
        
        let difference = try await blended(with: graphic, blendingMode: .difference, placement: .stretch)
        
        let color = try await difference.averagePixelColor
                
        return color.brightness < 0.000_1
    }
}
