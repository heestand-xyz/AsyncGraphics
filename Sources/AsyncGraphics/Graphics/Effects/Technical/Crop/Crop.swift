//
//  Created by Anton Heestand on 2023-04-27.
//

import CoreGraphics
import CoreGraphicsExtensions
import TextureMap
import PixelColor

extension Graphic {
    
    private struct CropUniforms {
        let origin: PointUniform
        let size: SizeUniform
    }
    
    public func pixel(u: CGFloat, v: CGFloat, options: EffectOptions = []) async throws -> PixelColor {
        let x: Int = Int(round(CGFloat(width - 1) * u))
        let y: Int = Int(round(CGFloat(height - 1) * v))
        return try await pixel(x: x, y: y, options: options)
    }
    
    public func pixel(x: Int, y: Int, options: EffectOptions = []) async throws -> PixelColor {
        let x: Int = min(max(x, 0), Int(width) - 1)
        let y: Int = min(max(y, 0), Int(height) - 1)
        let origin = CGPoint(x: x, y: y)
        let size = CGSize(width: 1, height: 1)
        let frame = CGRect(origin: origin, size: size)
        let graphic: Graphic = try await crop(to: frame, options: options)
        return try await graphic.pixelColors[0][0]
    }
    
    public func row(v: CGFloat, options: EffectOptions = []) async throws -> Graphic {
        let index: Int = Int(round(CGFloat(height - 1) * v))
        return try await row(index, options: options)
    }
    
    public func row(_ index: Int, options: EffectOptions = []) async throws -> Graphic {
        let index: Int = min(max(index, 0), Int(height) - 1)
        let origin = CGPoint(x: 0, y: index)
        let size = CGSize(width: width, height: 1)
        let frame = CGRect(origin: origin, size: size)
        return try await crop(to: frame, options: options)
    }
    
    public func column(u: CGFloat, options: EffectOptions = []) async throws -> Graphic {
        let index: Int = Int(round(CGFloat(width - 1) * u))
        return try await column(index, options: options)
    }
    
    public func column(_ index: Int, options: EffectOptions = []) async throws -> Graphic {
        let index: Int = min(max(index, 0), Int(width) - 1)
        let origin = CGPoint(x: index, y: 0)
        let size = CGSize(width: 1, height: height)
        let frame = CGRect(origin: origin, size: size)
        return try await crop(to: frame, options: options)
    }
    
    public func crop(to frame: CGRect, options: EffectOptions = []) async throws -> Graphic {
        
        let resolution: CGSize = frame.size
        
        let relativeOrigin: CGPoint = frame.origin / self.resolution
        let relativeSize: CGSize = frame.size / self.resolution
        
        return try await Renderer.render(
            name: "Crop",
            shader: .name("crop"),
            graphics: [self],
            uniforms: CropUniforms(
                origin: relativeOrigin.uniform,
                size: relativeSize.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
