//
//  Image.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
import Metal
import TextureMap
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import UniformTypeIdentifiers

extension Graphic {
    
    enum ImageError: LocalizedError {
        
        case imageNotFound
        case rawPhotoNotSupported
        case rawPhotoCorrupt
        case imageDataCorrupt
        
        var errorDescription: String? {
            switch self {
            case .imageNotFound:
                return "AsyncGraphics - Image - Not Found"
            case .rawPhotoNotSupported:
                return "AsyncGraphics - Image - RAW Photo Not Supported"
            case .rawPhotoCorrupt:
                return "AsyncGraphics - Image - RAW Photo Corrupt"
            case .imageDataCorrupt:
                return "AsyncGraphics - Image - Data Corrupt"
            }
        }
    }
    
    public struct ImageOptions: OptionSet, Hashable, Sendable {
        
        public let rawValue: Int
        
        /// Correct Color
        ///
        /// Applies color space correction and convert monochrome images to RGBA
        public static let colorCorrection = ImageOptions(rawValue: 1 << 0)
        
        /// Correct Orientation
        ///
        /// Not available on `macOS`
        public static let orientationCorrection = ImageOptions(rawValue: 1 << 1)
        
        public static var `default`: ImageOptions {
            [.colorCorrection, .orientationCorrection]
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// UIImage / NSImage
    public static func image(
        _ image: TMImage,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        
        let bits: TMBits = try image.bits
        let colorSpace: TMColorSpace = try image.colorSpace
        
        let texture: MTLTexture = try image.texture
        var graphic = Graphic(name: "Image", texture: texture, bits: bits, colorSpace: colorSpace)
        
        if options.contains(.colorCorrection) {
            
            if colorSpace == .nonLinearSRGB, bits == ._8 {
                graphic = try await graphic.convertColorSpace(from: .linearSRGB, to: .nonLinearSRGB)
            }
            
            if colorSpace.isMonochrome {
                graphic = try await graphic.channelMix(
                    green: .red,
                    blue: .red,
                    alpha: .green
                )
                .assignColorSpace(.sRGB)
            } else {
                /// Fix for different texture pixel formats
                graphic = try await graphic
                    .brightness(1.0) /// Has no visual effect
            }
        }
        
#if canImport(UIKit)
        if options.contains(.orientationCorrection) {
            graphic = try await graphic.rotate(to: image.imageOrientation)
        }
#endif
        
        return graphic
    }
    
    public static func image(
        _ cgImage: CGImage,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        let image = try TextureMap.image(cgImage: cgImage)
        return try await .image(image, options: options)
    }
    
    public static func image(
        _ ciImage: CIImage,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        let image = try TextureMap.image(ciImage: ciImage)
        return try await .image(image, options: options)
    }
    
    public static func image(
        named name: String,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        
        try await image(named: name, in: .main)
    }
    
    public static func image(
        named name: String,
        in bundle: Bundle,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        
        let image = try bundle.image(named: name)
        
        return try await .image(image, options: options)
    }
    
    public static func image(
        url: URL,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        
        if isRAWImage(url: url) {
            return try await rawImage(url: url)
        }
        
        let data = try Data(contentsOf: url)
        
        guard let image = TMImage(data: data) else {
            throw ImageError.imageNotFound
        }
        
        return try await .image(image, options: options)
    }
    
    public static func image(
        data: Data,
        options: ImageOptions = .default
    ) async throws -> Graphic {
        
        guard let image = TMImage(data: data) else {
            throw ImageError.imageDataCorrupt
        }
        
        return try await .image(image, options: options)
    }
    
    public static func isRAWImage(url: URL) -> Bool {
        
        guard let type: UTType = UTType(filenameExtension: url.pathExtension) else {
            return false
        }
        
        return type.conforms(to: .rawImage)
    }
    
    /// RAW Image - Canon, Nikon, Sony etc.
//    @available(*, deprecated, message: "Please use the sync function in a task.")
    public static func rawImage(url: URL) async throws -> Graphic {
        
        try await withCheckedThrowingContinuation { continuation in
                
            do {
                let graphic: Graphic = try rawImage(url: url)
                continuation.resume(returning: graphic)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public static func rawImage(url: URL) throws -> Graphic {
        
        guard let rawFilter = CIRAWFilter(imageURL: url) else {
            throw ImageError.rawPhotoNotSupported
        }
        
        guard let rawImage: CIImage = rawFilter.outputImage else {
            throw ImageError.rawPhotoCorrupt
        }
        
        let bits: TMBits = ._16
        let colorSpace: TMColorSpace = .xdr
        
        let texture: MTLTexture = try TextureMap.texture(ciImage: rawImage, colorSpace: colorSpace, bits: bits)
        
        return Graphic(name: "RAW Image", texture: texture, bits: bits, colorSpace: colorSpace)
    }
}

extension Graphic {
    
    #if canImport(UIKit)
    private func rotate(to orientation: UIImage.Orientation) async throws -> Graphic {
        switch orientation {
        case .down, .downMirrored:
            return try await rotated(.degrees(180))
        case .left, .leftMirrored:
            return try await rotatedLeft()
        case .right, .rightMirrored:
            return try await rotatedRight()
        case .up, .upMirrored:
            return self
        @unknown default:
            return self
        }
    }
    #endif
}
