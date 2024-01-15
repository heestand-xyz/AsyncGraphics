//
//  Created by Anton Heestand on 2023-04-28.
//

import Foundation
import Spatial
import TextureMap
import PixelColor
import MetalKit

extension Graphic3D {
    
    enum VoxelsError: LocalizedError {
        case unsupportedOS
        case noVoxels
        var errorDescription: String? {
            switch self {
            case .unsupportedOS:
                return "AsyncGraphics - Voxels - Unsupported OS"
            case .noVoxels:
                return "AsyncGraphics - Voxels - No Voxels"
            }
        }
    }
    
    public static func voxels(_ voxels: [[[PixelColor]]], options: ContentOptions = []) throws -> Graphic3D {
        
        let depth: Int = voxels.count
        guard depth > 0 else {
            throw VoxelsError.noVoxels
        }
        let height: Int = voxels.first!.count
        guard height > 0 else {
            throw VoxelsError.noVoxels
        }
        let width: Int = voxels.first!.first!.count
        
        let resolution = Size3D(width: Double(width),
                                height: Double(height),
                                depth: Double(depth))
                
        let texture: MTLTexture
        switch options.bits {
        case ._8:
            let channels: [UInt8] = voxels.flatMap { plane in
                plane.flatMap { row in
                    row.flatMap { color in
                        color.components.map { channel in
                            UInt8(min(max(channel, 0.0), 1.0) * 255)
                        }
                    }
                }
            }
            texture = try TextureMap.texture3d(channels: channels, resolution: resolution, on: Renderer.metalDevice)
        case ._16:
#if os(macOS)
            throw VoxelsError.unsupportedOS
#else
            let channels: [Float16] = voxels.flatMap { plane in
                plane.flatMap { row in
                    row.flatMap { color in
                        color.components.map { channel in
                            Float16(channel)
                        }
                    }
                }
            }
            texture = try TextureMap.texture3d(channels: channels, resolution: resolution, on: Renderer.metalDevice)
#endif
        case ._32:
            let channels: [Float] = voxels.flatMap { plane in
                plane.flatMap { row in
                    row.flatMap { color in
                        color.components.map { channel in
                            Float(channel)
                        }
                    }
                }
            }
            texture = try TextureMap.texture3d(channels: channels, resolution: resolution, on: Renderer.metalDevice)
        }
        
        return try .texture(texture)
    }
    
    /// 8 bit
    public static func channels(_ channels: [UInt8], resolution: Size3D) async throws -> Graphic3D {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let graphic: Graphic3D = try.channels(channels, resolution: resolution)
                    continuation.resume(returning: graphic)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    /// 8 bit
    public static func channels(_ channels: [UInt8], resolution: Size3D) throws -> Graphic3D {
        let texture: MTLTexture = try TextureMap.texture3d(channels: channels, resolution: resolution, on: Renderer.metalDevice)
        return try .texture(texture)
    }
    /// 8 bit
    public static func channels(pointer: UnsafePointer<UInt8>, resolution: Size3D) throws -> Graphic3D {
        let texture: MTLTexture = try TextureMap.texture3d(raw: pointer, resolution: resolution, on: Renderer.metalDevice)
        return try .texture(texture)
    }
    
#if !os(macOS)
    /// 16 bit
    public static func channels(_ channels: [Float16], resolution: Size3D) throws -> Graphic3D {
        let texture: MTLTexture = try TextureMap.texture3d(channels: channels, resolution: resolution, on: Renderer.metalDevice)
        return try .texture(texture)
    }
    /// 16 bit
    public static func channels(pointer: UnsafePointer<Float16>, resolution: Size3D) throws -> Graphic3D {
        let texture: MTLTexture = try TextureMap.texture3d(raw: pointer, resolution: resolution, on: Renderer.metalDevice)
        return try .texture(texture)
    }
#endif
    
    /// 32 bit
    public static func channels(_ channels: [Float], resolution: Size3D) throws -> Graphic3D {
        let texture: MTLTexture = try TextureMap.texture3d(channels: channels, resolution: resolution, on: Renderer.metalDevice)
        return try .texture(texture)
    }
    /// 32 bit
    public static func channels(pointer: UnsafePointer<Float>, resolution: Size3D) throws -> Graphic3D {
        let texture: MTLTexture = try TextureMap.texture3d(raw: pointer, resolution: resolution, on: Renderer.metalDevice)
        return try .texture(texture)
    }
}
