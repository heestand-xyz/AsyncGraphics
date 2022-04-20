//
//  Created by Anton Heestand on 2022-04-02.
//

import Metal
import TextureMap

//@available(iOS 14.0, tvOS 14, macOS 11, *)
extension Graphic {
    
    public func bits(_ bits: TMBits) async throws -> Graphic {
        
        Graphic(name: "Bits", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
//    public func with(bits: TMBits) async throws -> Graphic {
//
//        guard self.bits != bits else {
//            return self
//        }
//
//        let bitTexture: MTLTexture = try await withCheckedThrowingContinuation { continuation in
//
//            DispatchQueue.global(qos: .userInteractive).async {
//
//                do {
//
//                    switch self.bits {
//                    case ._8:
//
//                        switch bits {
//                        case ._8:
//
//                            break
//
//                        case ._16:
//
//                            let channels: [UInt8] = try TextureMap.raw8(texture: metalTexture)
//                            var mappedChannels: [Float16] = channels.map { channel in
//                                Float16(channel) / 255
//                            }
//
//                            let texture = try TextureMap.texture(raw: &mappedChannels,
//                                                                 size: resolution,
//                                                                 on: Renderer.metalDevice)
//
//                            DispatchQueue.main.async {
//                                continuation.resume(returning: texture)
//                            }
//
//                        }
//
//                    case ._16:
//
//                        switch bits {
//                        case ._8:
//
//                            let channels: [Float16] = try TextureMap.raw16(texture: metalTexture)
//                            var mappedChannels: [UInt8] = channels.map { channel in
//                                UInt8(channel * 255)
//                            }
//
//                            let texture = try TextureMap.texture(raw: &mappedChannels,
//                                                                 size: resolution,
//                                                                 on: Renderer.metalDevice)
//
//                            DispatchQueue.main.async {
//                                continuation.resume(returning: texture)
//                            }
//
//                        case ._16:
//
//                            break
//                        }
//                    }
//                } catch {
//
//                    DispatchQueue.main.async {
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//        }
//
//        return Graphic(metalTexture: bitTexture, bits: bits, colorSpace: colorSpace)
//    }
}
