import CoreGraphics
import Metal
import PixelColor
import TextureMap

extension Graphic {

    public enum RasterizedPathError: LocalizedError {
        case invalidResolution
        case bitmapCreationFailed
        case textureCreationFailed

        public var errorDescription: String? {
            switch self {
            case .invalidResolution: "AsyncGraphics - Rasterized Path - Invalid resolution."
            case .bitmapCreationFailed: "AsyncGraphics - Rasterized Path - Could not create the bitmap."
            case .textureCreationFailed: "AsyncGraphics - Rasterized Path - Could not create the texture."
            }
        }
    }

    private struct RasterizedPathUniforms: Uniforms {
        let premultiply: Bool
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
    }

    /// Rasterize an Apple/CoreGraphics path without constructing a SwiftUI view.
    /// Coordinates are pixels from the top left, matching the GPU shape APIs.
    /// Geometry coverage is an 8-bit CGContext bitmap; colors retain the requested output depth.
    public static func rasterizedPath(
        _ path: CGPath,
        fillRule: CGPathFillRule = .winding,
        stroke: StrokeStyle? = nil,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        resolution: CGSize,
        options: ContentOptions = []
    ) async throws -> Graphic {
        let outline = try stroke.map { try strokeOutline(of: path, style: $0) } ?? path
        let mask = try rasterizedPathMask(outline, fillRule: fillRule, resolution: resolution,
                                          antiAlias: options.antiAlias)
        if color == .white, backgroundColor == .black, options.bits == ._8, options.colorSpace == .sRGB {
            return mask
        }
        return try await Renderer.render(
            name: "Rasterized Path",
            shader: .name("rasterizedPathColor"),
            graphics: [mask],
            uniforms: RasterizedPathUniforms(
                premultiply: options.premultiply,
                foregroundColor: color.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform
            ),
            metadata: Renderer.Metadata(resolution: mask.resolution, colorSpace: options.colorSpace, bits: options.bits)
        )
    }

    private static func rasterizedPathMask(
        _ path: CGPath,
        fillRule: CGPathFillRule,
        resolution: CGSize,
        antiAlias: Bool
    ) throws -> Graphic {
        guard resolution.width.isFinite, resolution.height.isFinite,
              resolution.width >= 1, resolution.height >= 1,
              resolution.width <= 16_384, resolution.height <= 16_384 else {
            throw RasterizedPathError.invalidResolution
        }
        let width = Int(resolution.width)
        let height = Int(resolution.height)
        let bytesPerRow = width * 4
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
              let bytes = context.data else {
            throw RasterizedPathError.bitmapCreationFailed
        }
        context.setFillColor(gray: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setAllowsAntialiasing(antiAlias)
        context.setShouldAntialias(antiAlias)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        context.setFillColor(gray: 1, alpha: 1)
        context.addPath(path)
        context.drawPath(using: fillRule == .evenOdd ? .eoFill : .fill)

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                  width: width, height: height, mipmapped: false)
        descriptor.usage = [.shaderRead, .renderTarget]
        guard let texture = Renderer.metalDevice.makeTexture(descriptor: descriptor) else {
            throw RasterizedPathError.textureCreationFailed
        }
        texture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0,
                        withBytes: bytes, bytesPerRow: bytesPerRow)
        return Graphic(name: "Path Coverage", texture: texture, bits: ._8, colorSpace: .sRGB)
    }
}
