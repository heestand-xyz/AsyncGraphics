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
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedType:
                return "AsyncGraphics - Graphic - Buffer - Unsupported Type"
            }
        }
    }
    
    public static func pixelBuffer(_ pixelBuffer: CVPixelBuffer) throws -> Graphic {
        try texture(TextureMap.texture(pixelBuffer: pixelBuffer))
    }

    public static func sampleBuffer(_ sampleBuffer: CMSampleBuffer) throws -> Graphic {
        try texture(TextureMap.texture(sampleBuffer: sampleBuffer))
    }
}
