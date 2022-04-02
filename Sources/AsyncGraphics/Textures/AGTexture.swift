//
//  AGTexture.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
import Metal
import TextureMap

public struct AGTexture {
    
    public let metalTexture: MTLTexture
    
    public let bits: TMBits
    public let colorSpace: TMColorSpace
}

// MARK: - Resolution

extension AGTexture {
    
    public var resolution: CGSize {
        metalTexture.size
    }
}

// MARK: - Image

extension AGTexture {
    
    public var image: TMImage {
        get async throws {
            try await metalTexture.image(colorSpace: colorSpace, bits: bits)
        }
    }
}

// MARK: - Equatable

extension AGTexture: Equatable {
    
    public static func == (lhs: AGTexture, rhs: AGTexture) -> Bool {
        
        guard lhs.resolution == rhs.resolution else {
            return false
        }
        
        return lhs.metalTexture.hash == rhs.metalTexture.hash
    }
}

//extension AGTexture: Comparable {
//    
//}
