//
//  Image+Stereoscopic.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/24.
//

import Foundation
import TextureMap
import ImageIO

extension Graphic {
    enum StereoscopicError: String, LocalizedError {
        case imageSourceCreateFailed
        case imageSourcePropertiesNotFound
        case imageGroupsNotFound
        case imageStereoPairNotFound
        case imageStereoPropertiesNotFound
        case imageIsNotStereoscopic
        case imageNotFound
        var errorDescription: String? {
            switch self {
            case .imageSourceCreateFailed:
                "AsyncGraphics: Image source create failed"
            case .imageSourcePropertiesNotFound:
                "AsyncGraphics: Image source properties not found."
            case .imageGroupsNotFound:
                "AsyncGraphics: Image groups not found."
            case .imageStereoPairNotFound:
                "AsyncGraphics: Image stereo pair not found."
            case .imageStereoPropertiesNotFound:
                "AsyncGraphics: Image stereo properties not found."
            case .imageIsNotStereoscopic:
                "AsyncGraphics: Image is not stereoscopic."
            case .imageNotFound:
                "AsyncGraphics: Image not found."
            }
        }
    }
    
    public static func isStereoscopicImage(url: URL) -> Bool {
        guard let imageSource: CGImageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return false }
        return isStereoscopic(source: imageSource)
    }
    
    public static func isStereoscopic(image: TMImage) -> Bool {
        guard let cgImage: CGImage = image.cgImage else { return false }
        guard let imageSource: CGImageSource = try? TextureMap.cgImageSource(cgImage: cgImage) else { return false }
        return isStereoscopic(source: imageSource)
    }
    
    public static func isStereoscopic(source: CGImageSource) -> Bool {
        let imageCount: Int = CGImageSourceGetCount(source)
        guard imageCount >= 2 else { return false }
        guard let properties = CGImageSourceCopyProperties(source, nil) as? [CFString: Any] else {
            return false
        }
        guard let groups = properties[kCGImagePropertyGroups] as? [[CFString: Any]] else {
            return false
        }
        guard let stereoGroup = groups.first(where: {
            let groupType = $0[kCGImagePropertyGroupType] as! CFString
            return groupType == kCGImagePropertyGroupTypeStereoPair
        }) else {
            return false
        }
        guard stereoGroup[kCGImagePropertyGroupImageIndexLeft] as? Int != nil,
              stereoGroup[kCGImagePropertyGroupImageIndexRight] as? Int != nil else {
            return false
        }
        return true
    }
    
    public static func stereoscopicGraphics(url: URL) async throws -> (left: Graphic, right: Graphic) {
        let (leftImage, rightImage): (TMImage, TMImage) = try stereoscopicImages(url: url)
        let (leftSendableImage, rightSendableImage): (TMSendableImage, TMSendableImage) = (leftImage.send(), rightImage.send())
        async let (leftGraphic, rightGraphic): (Graphic, Graphic) = (.image(sendable: leftSendableImage), .image(sendable: rightSendableImage))
        return try await (leftGraphic, rightGraphic)
    }
    
    public static func stereoscopicGraphics(image: TMImage) async throws -> (left: Graphic, right: Graphic) {
        let (leftImage, rightImage): (TMImage, TMImage) = try stereoscopicImages(image: image)
        let (leftSendableImage, rightSendableImage): (TMSendableImage, TMSendableImage) = (leftImage.send(), rightImage.send())
        async let (leftGraphic, rightGraphic): (Graphic, Graphic) = (.image(sendable: leftSendableImage), .image(sendable: rightSendableImage))
        return try await (leftGraphic, rightGraphic)
    }
    
    public static func stereoscopicGraphics(source: CGImageSource) async throws -> (left: Graphic, right: Graphic) {
        let (leftImage, rightImage): (TMImage, TMImage) = try stereoscopicImages(source: source)
        let (leftSendableImage, rightSendableImage): (TMSendableImage, TMSendableImage) = (leftImage.send(), rightImage.send())
        async let (leftGraphic, rightGraphic): (Graphic, Graphic) = (.image(sendable: leftSendableImage), .image(sendable: rightSendableImage))
        return try await (leftGraphic, rightGraphic)
    }
    
    public static func stereoscopicImages(url: URL) throws -> (left: TMImage, right: TMImage) {
        let imageSource: CGImageSource = try TextureMap.cgImageSource(url: url)
        return try stereoscopicImages(source: imageSource)
    }
    
    public static func stereoscopicImages(image: TMImage) throws -> (left: TMImage, right: TMImage) {
        guard let cgImage: CGImage = image.cgImage else {
            throw StereoscopicError.imageNotFound
        }
        let imageSource: CGImageSource = try TextureMap.cgImageSource(cgImage: cgImage)
        return try stereoscopicImages(source: imageSource)
    }
    
    public static func stereoscopicImages(source: CGImageSource) throws -> (left: TMImage, right: TMImage) {
        let imageCount: Int = CGImageSourceGetCount(source)
        guard imageCount >= 2 else {
            throw StereoscopicError.imageIsNotStereoscopic
        }
        guard let properties = CGImageSourceCopyProperties(source, nil) as? [CFString: Any] else {
            throw StereoscopicError.imageSourcePropertiesNotFound
        }
        guard let groups = properties[kCGImagePropertyGroups] as? [[CFString: Any]] else {
            throw StereoscopicError.imageGroupsNotFound
        }
        guard let stereoGroup = groups.first(where: {
            let groupType = $0[kCGImagePropertyGroupType] as! CFString
            return groupType == kCGImagePropertyGroupTypeStereoPair
        }) else {
            throw StereoscopicError.imageStereoPairNotFound
        }
        guard let leftIndex = stereoGroup[kCGImagePropertyGroupImageIndexLeft] as? Int,
              let rightIndex = stereoGroup[kCGImagePropertyGroupImageIndexRight] as? Int,
              let leftCGImage = CGImageSourceCreateImageAtIndex(source, leftIndex, nil),
              let rightCGImage = CGImageSourceCreateImageAtIndex(source, rightIndex, nil) else {
            throw StereoscopicError.imageStereoPropertiesNotFound
        }
        let leftImage = try TextureMap.image(cgImage: leftCGImage)
        let rightImage = try TextureMap.image(cgImage: rightCGImage)
        return (leftImage, rightImage)
    }
}
