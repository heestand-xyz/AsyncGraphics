//
//  Created by Anton Heestand on 2022-04-03.
//

import Spatial
import PixelColor

extension Graphic3D {
    
    private struct Cone3DUniforms {
        let axis: UInt32
        let premultiply: Bool
        let antiAlias: Bool
        let leadingRadius: Float
        let trailingRadius: Float
        let length: Float
        let position: VectorUniform
        let surfaceWidth: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public static func cone(
        axis: Axis = .z,
        length: Double? = nil,
        leadingRadius: Double? = nil,
        trailingRadius: Double? = nil,
        position: Point3D? = nil,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clearWhite,
        resolution: Size3D,
        options: ContentOptions = []
    ) async throws -> Graphic3D {
        
        let leadingRadius: Double = leadingRadius ?? min(resolution.width, resolution.height, resolution.depth) / 2
        let relativeLeadingRadius: Double = leadingRadius / resolution.height
        
        let trailingRadius: Double = trailingRadius ?? 0.0
        let relativeTrailingRadius: Double = trailingRadius / resolution.height
        
        let length: Double = length ?? {
            switch axis {
            case .x:
                resolution.width
            case .y:
                resolution.height
            case .z:
                resolution.depth
            }
        }()
        let relativeLength: Double = length / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / resolution.height
        
        return try await Renderer.render(
            name: "Cone 3D",
            shader: .name("cone3d"),
            uniforms: Cone3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                leadingRadius: Float(relativeLeadingRadius),
                trailingRadius: Float(relativeTrailingRadius),
                length: Float(relativeLength),
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
    
    public static func surfaceCone(
        axis: Axis = .z,
        length: Double? = nil,
        leadingRadius: Double? = nil,
        trailingRadius: Double? = nil,
        position: Point3D? = nil,
        surfaceWidth: Double,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clearWhite,
        resolution: Size3D,
        options: ContentOptions = []
    ) async throws -> Graphic3D {
        
        let leadingRadius: Double = leadingRadius ?? min(resolution.width, resolution.height, resolution.depth) / 2
        let relativeLeadingRadius: Double = leadingRadius / resolution.height
        
        let trailingRadius: Double = trailingRadius ?? 0.0
        let relativeTrailingRadius: Double = trailingRadius / resolution.height
        
        let length: Double = length ?? {
            switch axis {
            case .x:
                resolution.width
            case .y:
                resolution.height
            case .z:
                resolution.depth
            }
        }() - surfaceWidth
        let relativeLength: Double = length / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / resolution.height
        
        let relativeSurfaceWidth: Double = surfaceWidth / resolution.height
        
        return try await Renderer.render(
            name: "Cone 3D",
            shader: .name("cone3d"),
            uniforms: Cone3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                leadingRadius: Float(relativeLeadingRadius),
                trailingRadius: Float(relativeTrailingRadius),
                length: Float(relativeLength),
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
