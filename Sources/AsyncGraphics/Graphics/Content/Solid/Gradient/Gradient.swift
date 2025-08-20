//
//  Created by Anton Heestand on 2022-05-23.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct GradientUniforms: Uniforms {
        let type: UInt32
        let extend: UInt32
        let scale: Float
        let offset: Float
        let position: PointUniform
        let gamma: Float
        let premultiply: Bool
        let resolution: SizeUniform
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }
    
    struct GradientColorStopUniforms: Uniforms {
        let fraction: Float
        let color: ColorUniform
    }
    
    /// Gradient Stop is a color with a location between 0.0 and 1.0
    public struct GradientStop: Codable, Equatable, Sendable {
        /// A location between 0.0 and 1.0
        public var location: CGFloat
        public var color: PixelColor
        public init(at location: CGFloat, color: PixelColor) {
            self.location = location
            self.color = color
        }
    }
    
    @EnumMacro
    public enum GradientDirection: String, GraphicEnum {
        case horizontal
        case vertical
        case radial
        case angle
    }
    
    @EnumMacro
    public enum GradientExtend: String, GraphicEnum {
        case zero
        case hold
        case loop
        case mirror
    }
    
    public static func gradient(direction: GradientDirection,
                                stops: [GradientStop] = [
                                    GradientStop(at: 0.0, color: .black),
                                    GradientStop(at: 1.0, color: .white)
                                ],
                                position: CGPoint? = nil,
                                scale: CGFloat = 1.0,
                                offset: CGFloat = 0.0,
                                extend: GradientExtend = .zero,
                                gamma: CGFloat = 1.0,
                                resolution: CGSize,
                                tile: Tile = .one,
                                options: ContentOptions = []) async throws -> Graphic {
        
        let position: CGPoint = position ?? (resolution.asPoint / 2)
        let relativePosition: CGPoint = (position - resolution / 2) / resolution.height
        
        var colorStops: [GradientColorStopUniforms] = stops.map { stop in
            GradientColorStopUniforms(
                fraction: Float(stop.location),
                color: stop.color.uniform
            )
        }
        
        if !colorStops.contains(where: { $0.fraction == 0.0 }) {
            colorStops.insert(GradientColorStopUniforms(fraction: 0.0, color: colorStops.sorted(by: { $0.fraction < $1.fraction }).first?.color ?? .clear), at: 0)
        }
        
        if !colorStops.contains(where: { $0.fraction == 1.0 }) {
            colorStops.append(GradientColorStopUniforms(fraction: 1.0, color: colorStops.sorted(by: { $0.fraction < $1.fraction }).last?.color ?? .clear))
        }
        
        return try await Renderer.render(
            name: "Gradient",
            shader: .name("gradient"),
            uniforms: GradientUniforms(
                type: direction.index,
                extend: extend.index,
                scale: Float(scale),
                offset: Float(offset),
                position: relativePosition.uniform,
                gamma: Float(gamma),
                premultiply: options.premultiply,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            arrayUniforms: colorStops,
            emptyArrayUniform: GradientColorStopUniforms(
                fraction: 0.0,
                color: PixelColor.clear.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
