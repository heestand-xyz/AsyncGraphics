//
//  Image+Stereoscopic.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/24.
//

import Foundation
import TextureMap
import ImageIO
import UniformTypeIdentifiers

extension Graphic {
    enum StereoscopicError: String, LocalizedError {
        case imageSourceCreateFailed
        case imageSourcePropertiesNotFound
        case imageGroupsNotFound
        case imageStereoPairNotFound
        case imageStereoPropertiesNotFound
        case imageIsNotStereoscopic
        case imageNotFound
        case stereoscopicResolutionMismatch
        case failedToCreateStereoImage
        case failedToFinializeStereoImage
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
            case .stereoscopicResolutionMismatch:
                "AsyncGraphics: Stereoscopic resolution mismatch."
            case .failedToCreateStereoImage:
                "AsyncGraphics: Failed to create stereo image."
            case .failedToFinializeStereoImage:
                "AsyncGraphics: Failed to finalize stereo image."
            }
        }
    }
    
    /// Spatial HEIC Data
    public static func stereoscopicImageData(
        leftGraphic: Graphic,
        rightGraphic: Graphic,
        spatialMetadata: SpatialGraphicMetadata = .default
    ) async throws -> Data {
        guard leftGraphic.resolution == rightGraphic.resolution else {
            throw StereoscopicError.stereoscopicResolutionMismatch
        }
        let leftCGImage = try await leftGraphic.cgImage
        let rightCGImage = try await rightGraphic.cgImage
        let destinationProperties: [CFString: Any] = [
            kCGImagePropertyPrimaryImage: 0
        ]
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.heic.description as CFString,
            2,
            destinationProperties as CFDictionary
        ) else {
            throw StereoscopicError.failedToCreateStereoImage
        }
        CGImageDestinationAddImage(
            destination,
            leftCGImage,
            stereoscopicProperties(
                isLeft: true,
                with: spatialMetadata,
                at: leftGraphic.resolution
            ) as CFDictionary
        )
        CGImageDestinationAddImage(
            destination,
            rightCGImage,
            stereoscopicProperties(
                isLeft: false,
                with: spatialMetadata,
                at: rightGraphic.resolution
            ) as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else {
            throw StereoscopicError.failedToFinializeStereoImage
        }
        return data as Data
    }
    
    private static func stereoscopicProperties(
        isLeft: Bool,
        with spatialMetadata: SpatialGraphicMetadata,
        at resolution: CGSize
    ) -> [CFString: Any] {
        let identityRotation: [Double] = [
            1, 0, 0,
            0, 1, 0,
            0, 0, 1
        ]
        let baselineInMeters = spatialMetadata.baselineInMillimeters / 1000.0
        let leftPosition: [Double] = [0, 0, 0]
        let rightPosition: [Double] = [baselineInMeters, 0, 0]
        let position = isLeft ? leftPosition : rightPosition
        let intrinsics = intrinsics(fov: spatialMetadata.horizontalFOV, at: resolution)
        return [
            kCGImagePropertyGroups: [
                kCGImagePropertyGroupIndex: 0,
                kCGImagePropertyGroupType: kCGImagePropertyGroupTypeStereoPair,
                (isLeft ? kCGImagePropertyGroupImageIsLeftImage : kCGImagePropertyGroupImageIsRightImage): true,
                kCGImagePropertyGroupImageDisparityAdjustment: spatialMetadata.disparityAdjustment
            ],
            kCGImagePropertyHEIFDictionary: [
                kIIOMetadata_CameraExtrinsicsKey: [
                    kIIOCameraExtrinsics_Position: position,
                    kIIOCameraExtrinsics_Rotation: identityRotation
                ],
                kIIOMetadata_CameraModelKey: [
                    kIIOCameraModel_Intrinsics: intrinsics,
                    kIIOCameraModel_ModelType: kIIOCameraModelType_SimplifiedPinhole
                ]
            ],
            kCGImagePropertyHasAlpha: false
        ]
    }
    
    private static func intrinsics(fov: Double, at resolution: CGSize) -> [Double] {
        let horizontalFOVInRadians = fov / 180.0 * .pi
        let focalLengthX = (resolution.width * 0.5) / (tan(horizontalFOVInRadians * 0.5))
        let focalLengthY = focalLengthX
        let principalPointX = 0.5 * resolution.width
        let principalPointY = 0.5 * resolution.height
        return [
            focalLengthX, 0, principalPointX,
            0, focalLengthY, principalPointY,
            0, 0, 1
        ]
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
