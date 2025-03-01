//
//  Created by Anton Heestand on 2023-01-23.
//

import CoreVideo
import Metal
import TextureMap
import CoreMedia

extension Graphic {
    
    public enum BufferError: LocalizedError {
        
        case unsupportedType
        case cmSampleBufferGetImageBufferFailed
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedType:
                "AsyncGraphics - Graphic - Buffer - Unsupported Type"
            case .cmSampleBufferGetImageBufferFailed:
                "AsyncGraphics - Graphic - Buffer - CM Sample Buffer to Pixel Buffer Failed"
            }
        }
    }
    
    public static func pixelBuffer(_ pixelBuffer: CVPixelBuffer) throws -> Graphic {
        try texture(TextureMap.texture(pixelBuffer: pixelBuffer))
    }
    
    public static func sampleBuffer(_ sampleBuffer: CMSampleBuffer) async throws -> Graphic {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { throw BufferError.cmSampleBufferGetImageBufferFailed }
        let osType: OSType = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let isVUV: Bool = osType == OSType(875704438)
        if isVUV {
            let yTexture: MTLTexture = try TextureMap.texture(pixelBuffer: pixelBuffer, planeIndex: 0)
            let uvTexture: MTLTexture = try TextureMap.texture(pixelBuffer: pixelBuffer, planeIndex: 1)
            let yGraphic: Graphic = try .texture(yTexture)
            let uvGraphic: Graphic = try .texture(uvTexture)
            return try await .rgb(y: yGraphic, uv: uvGraphic)
        } else {
            let texture: MTLTexture = try TextureMap.texture(pixelBuffer: pixelBuffer)
            var graphic: Graphic = try .texture(texture)
            let isGrayscale: Bool = osType == OSType(1278226488)
            if isGrayscale {
                graphic = try await graphic.channelMix(
                    green: .red,
                    blue: .red,
                    alpha: .one
                )
            }
            return graphic
        }
    }
}
