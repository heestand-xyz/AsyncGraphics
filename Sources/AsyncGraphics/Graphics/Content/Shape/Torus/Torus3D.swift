//
//  Created by Anton Heestand on 2022-04-03.
//

import Spatial
import PixelColor

extension Graphic3D {
    
    private struct Torus3DUniforms {
        let axis: UInt32
        let premultiply: Bool
        let antiAlias: Bool
        let radius: Float
        let revolvingRadius: Float
        let position: VectorUniform
        let surfaceWidth: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public static func torus(
        axis: Axis = .z,
        radius: Double? = nil,
        revolvingRadius: Double? = nil,
        position: Point3D? = nil,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clearWhite,
        resolution: Size3D,
        options: ContentOptions = []
    ) async throws -> Graphic3D {
        
        let radius: Double = radius ?? min(resolution.width, resolution.height, resolution.depth) / 4
        let relativeRadius: Double = radius / resolution.height
        
        let revolvingRadius: Double = revolvingRadius ?? min(resolution.width, resolution.height, resolution.depth) / 8
        let relativeRevolvingRadius: Double = revolvingRadius / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition = (position - Point3D(resolution) / 2) / resolution.height
        
        return try await Renderer.render(
            name: "Torus 3D",
            shader: .name("torus3d"),
            uniforms: Torus3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                revolvingRadius: Float(relativeRevolvingRadius),
                position: relativePosition.uniform,
                surfaceWidth: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func surfaceTorus(
        axis: Axis = .z,
        radius: Double? = nil,
        revolvingRadius: Double? = nil,
        position: Point3D? = nil,
        surfaceWidth: Double,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clearWhite,
        resolution: Size3D,
        options: ContentOptions = []
    ) async throws -> Graphic3D {
        
        let radius: Double = radius ?? min(resolution.width, resolution.height, resolution.depth) / 4
        let relativeRadius: Double = radius / resolution.height
        
        let revolvingRadius: Double = revolvingRadius ?? min(resolution.width, resolution.height, resolution.depth) / 8
        let relativeRevolvingRadius: Double = revolvingRadius / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition = (position - Point3D(resolution) / 2) / resolution.height
        
        let relativeSurfaceWidth: Double = surfaceWidth / resolution.height
        
        return try await Renderer.render(
            name: "Torus 3D",
            shader: .name("torus3d"),
            uniforms: Torus3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                revolvingRadius: Float(relativeRevolvingRadius),
                position: relativePosition.uniform,
                surfaceWidth: Float(relativeSurfaceWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
