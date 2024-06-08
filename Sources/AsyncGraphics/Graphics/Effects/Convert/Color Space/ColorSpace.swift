//
//  Created by Anton Heestand on 2022-04-02.
//

import Metal
import TextureMap

extension Graphic {
    
    public func convertColorSpace(
        from leadingColorSpace: TMColorSpace,
        to trailingColorSpace: TMColorSpace
    ) async throws -> Graphic {
        
        let texture = try await texture.convertColorSpace(
            from: leadingColorSpace.cgColorSpace,
            to: trailingColorSpace.cgColorSpace
        )
        
        return Graphic(
            name: "Color Space",
            texture: texture,
            bits: bits,
            colorSpace: trailingColorSpace
        )
    }
    
    public func applyColorSpace(
        _ colorSpace: TMColorSpace
    ) async throws -> Graphic {
        
        let texture = try await texture.convertColorSpace(
            from: self.colorSpace.cgColorSpace,
            to: colorSpace.cgColorSpace
        )
        
        return Graphic(
            name: "Color Space",
            texture: texture,
            bits: bits,
            colorSpace: colorSpace
        )
    }
    
    public func assignColorSpace(
        _ colorSpace: TMColorSpace
    ) -> Graphic {
        
        Graphic(
            name: "Color Space",
            texture: texture,
            bits: bits,
            colorSpace: colorSpace
        )
    }
}
