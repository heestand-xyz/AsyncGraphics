//
//  Created by Anton Heestand on 2022-05-23.
//

import Spatial
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic3D {
    
    private struct Gradient3DUniforms {
        let type: UInt32
        let extend: UInt32
        let scale: Float
        let offset: Float
        let position: VectorUniform
        let gamma: Float
        let premultiply: Bool
        let resolution: VectorUniform
        let tileOrigin: VectorUniform
        let tileSize: VectorUniform
    }
    
    @EnumMacro
    public enum Gradient3DDirection: String, GraphicEnum {
        case x
        case y
        case z
        case radial
    }
    
    public static func gradient(direction: Gradient3DDirection,
                                stops: [Graphic.GradientStop] = [
                                    Graphic.GradientStop(at: 0.0, color: .black),
                                    Graphic.GradientStop(at: 1.0, color: .white)
                                ],
                                position: Point3D? = nil,
                                scale: CGFloat = 1.0,
                                offset: CGFloat = 0.0,
                                extend: Graphic.GradientExtend = .zero,
                                gamma: CGFloat = 1.0,
                                resolution: Size3D,
                                tile: Tile = .one,
                                options: ContentOptions = []) async throws -> Graphic3D {
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / resolution.height
        
        var colorStops: [Graphic.GradientColorStopUniforms] = stops.map { stop in
            Graphic.GradientColorStopUniforms(
                fraction: Float(stop.location),
                color: stop.color.uniform
            )
        }
        
        if !colorStops.contains(where: { $0.fraction == 0.0 }) {
            colorStops.insert(Graphic.GradientColorStopUniforms(fraction: 0.0, color: colorStops.sorted(by: { $0.fraction < $1.fraction }).first?.color ?? .clear), at: 0)
        }
        
        if !colorStops.contains(where: { $0.fraction == 1.0 }) {
            colorStops.append(Graphic.GradientColorStopUniforms(fraction: 1.0, color: colorStops.sorted(by: { $0.fraction < $1.fraction }).last?.color ?? .clear))
        }
        
        return try await Renderer.render(
            name: "Gradient 3D",
            shader: .name("gradient3d"),
            uniforms: Gradient3DUniforms(
                type: direction.index,
                extend: extend.index,
                scale: Float(scale),
                offset: Float(offset),
                position: relativePosition.uniform,
                gamma: Float(gamma),
                premultiply: options.premultiply,
                resolution: Point3D(resolution).uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            arrayUniforms: colorStops,
            emptyArrayUniform: Graphic.GradientColorStopUniforms(
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
