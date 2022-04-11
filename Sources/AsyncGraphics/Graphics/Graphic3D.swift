//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import simd
import CoreGraphics
import Metal
import TextureMap
import PixelColor

public struct Graphic3D: Graphicable {
    
    public let name: String
    
    public let texture: MTLTexture
    
    public let bits: TMBits
    public let colorSpace: TMColorSpace
}

// MARK: - Resolution

extension Graphic3D {
    
    public var resolution: SIMD3<Int> {
        SIMD3(texture.width, texture.height, texture.depth)
    }
}

// MARK: - Pixels

extension Graphic3D {
    
    enum Graphic3DPixelError: LocalizedError {
        
        case noChannelsFound
        case badChannelCount

        var errorDescription: String? {
            switch self {
            case .noChannelsFound:
                return "Async Graphic3Ds - Texture - Pixels - No Channels Found"
            case .badChannelCount:
                return "Async Graphic3Ds - Texture - Pixels - Bad Channel Count"
            }
        }
    }
    
    public var firstVoxelColor: PixelColor {

        get async throws {
            
            let channels: [CGFloat] = try await channels
            
            guard !channels.isEmpty, channels.count >= 4 else {
                throw Graphic3DPixelError.noChannelsFound
            }
            
            return PixelColor(red: channels[0],
                              green: channels[1],
                              blue: channels[2],
                              alpha: channels[3])
        }
    }
    
    public var averageVoxelColor: PixelColor {
        
        get async throws {
            
            let voxels: [PixelColor] = try await voxels.flatMap { $0.flatMap { $0 } }
            
            let color: PixelColor = voxels.reduce(.clear, +) / CGFloat(voxels.count)
            
            return color
        }
    }
    
    /// Voxels
    ///
    /// An array of planes of rows of colors.
    public var voxels: [[[PixelColor]]] {
        
        get async throws {
            
            let channels: [CGFloat] = try await channels
            
            guard !channels.isEmpty else {
                throw Graphic3DPixelError.noChannelsFound
            }
            
            let count = resolution.x * resolution.y * resolution.z * 4
            guard channels.count == count else {
                throw Graphic3DPixelError.badChannelCount
            }
            
            var voxels: [[[PixelColor]]] = []
            
            for z in 0..<Int(resolution.z) {
                
                var planes: [[PixelColor]] = []
                
                for y in 0..<resolution.y {
                    
                    var rows: [PixelColor] = []
                            
                    for x in 0..<resolution.x {
                
                        let index = z * resolution.y * resolution.x * 4 + y * resolution.x * 4 + x * 4
                        
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
                    
                    planes.append(rows)
                }
                
                voxels.append(planes)
            }
            
            return voxels
        }
    }
    
    public var channels: [CGFloat] {
        
        get async throws {
            
            try await TextureMap.rawNormalized3d(texture: texture, bits: bits)
        }
    }
}

// MARK: - Equal

//@available(iOS 14.0, tvOS 14, macOS 11, *)
//extension Graphic3D {
//
//    public func isEqual(to graphic: Graphic3D) async throws -> Bool {
//
//        guard resolution == graphic.resolution else {
//            return false
//        }
//
//        let difference = try await blended(with: graphic, blendingMode: .difference, placement: .stretch)
//
//        let color = try await difference.averagePixelColor
//
//        return color.brightness < 0.000_1
//    }
//}
