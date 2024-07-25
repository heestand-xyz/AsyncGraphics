//
//  Created by Anton Heestand on 2022-04-03.
//

import Spatial
import PixelColor

extension Graphic3D {
    
    private struct Sphere3DUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let radius: Float
        let position: VectorUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let tileOrigin: VectorUniform
        let tileSize: VectorUniform
    }
    
    public static func sphere(radius: Double? = nil,
                              position: Point3D? = nil,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .clear,
                              resolution: Size3D,
                              tile: Tile = .one,
                              options: ContentOptions = []) async throws -> Graphic3D {
        
        let radius: Double = radius ?? min(resolution.width, resolution.height, resolution.depth) / 2
        let relativeRadius: Double = radius / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution / 2)
        let relativePosition: Point3D = (position - resolution / 2) / resolution.height
        
        return try await Renderer.render(
            name: "Sphere 3D",
            shader: .name("sphere3d"),
            uniforms: Sphere3DUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func surfaceSphere(radius: Double? = nil,
                                     position: Point3D? = nil,
                                     surfaceWidth: Double = 1.0,
                                     color: PixelColor = .white,
                                     backgroundColor: PixelColor = .clear,
                                     resolution: Size3D,
                                     tile: Tile = .one,
                                     options: ContentOptions = []) async throws -> Graphic3D {
        
        let radius: Double = radius ?? min(resolution.width, resolution.height, resolution.depth) / 2
        let relativeRadius: Double = radius / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution / 2)
        let relativePosition: Point3D = (position - resolution / 2) / resolution.height
        
        let relativeSurfaceWidth: Double = surfaceWidth / resolution.height
        
        return try await Renderer.render(
            name: "Sphere 3D",
            shader: .name("sphere3d"),
            uniforms: Sphere3DUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(relativeSurfaceWidth),
                foregroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                edgeColor: color.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
