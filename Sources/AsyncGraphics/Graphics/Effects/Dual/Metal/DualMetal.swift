//
//  Created by Anton Heestand on 2022-04-20.
//

import Foundation
import CoreGraphics

extension Graphic {
    
    public enum DualMetalError: LocalizedError {
        
        case metalFileNotFound
        
        public var errorDescription: String? {
            switch self {
            case .metalFileNotFound:
                return "AsyncGraphics - Graphic - Metal - Metal File Not Found"
            }
        }
    }
    
    /// Metal
    ///
    /// Get the resolutions of the input textures.
    /// ```
    /// uint leadingWidth = leadingTexture.get_width();
    /// uint leadingHeight = leadingTexture.get_height();
    /// uint trailingWidth = trailingTexture.get_width();
    /// uint trailingHeight = trailingTexture.get_height();
    /// ```
    ///
    /// Return a `float4` color.
    /// ```
    /// return leadingColor + trailingColor;
    /// ```
    ///
    /// Available variables are:  `sampler`, `leadingTexture`, `trailingTexture`, `u`, `v`, `uv`, `leadingColor`, `trailingColor`.
    public func metal(with graphic: Graphic, code: String) async throws -> Graphic {
        
        guard let metalBaseURL = Bundle.module.url(forResource: "DualMetal.metal", withExtension: "txt") else {
            throw DualMetalError.metalFileNotFound
        }
        
        let metalBaseCode = try String(contentsOf: metalBaseURL)
        
        let metalCode = metalBaseCode
            .replacingOccurrences(of: "/*<code>*/", with: code)
            .replacingOccurrences(of: "return 0;", with: "")
        
        return try await Renderer.render(
            name: "Metal",
            shader: .code(metalCode, name: "dualMetal"),
            graphics: [self, graphic]
        )
    }
}
