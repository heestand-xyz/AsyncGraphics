//
//  Created by Anton Heestand on 2022-04-11.
//

import simd
import PixelColor

extension Graphic3D {
    //struct to hold the uniforms required for box3d
    private struct Box3DUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let size: VectorUniform
        let position: VectorUniform
        let cornerRadius: Float
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }

    //function to create 3D box
    public static func box(size: SIMD3<Double>,
                           origin: SIMD3<Double>,
                           cornerRadius: Double = 0.0,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .black,
                           resolution: SIMD3<Int>,
                           options: ContentOptions = ContentOptions()) async throws -> Graphic3D {

        //calculate center of box
        let center: SIMD3<Double> = SIMD3<Double>(
            origin.x + size.x / 2,
            origin.y + size.y / 2,
            origin.z + size.z / 2
        )

        //call box function with center as input
        return try await box(
            size: size,
            center: center,
            cornerRadius: cornerRadius,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }

    //function to create 3D box
    public static func box(size: SIMD3<Double>,
                           center: SIMD3<Double>? = nil,
                           cornerRadius: Double = 0.0,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .black,
                           resolution: SIMD3<Int>,
                           options: ContentOptions = ContentOptions()) async throws -> Graphic3D {

        //calculate relative size
        let relativeSize: SIMD3<Double> = SIMD3<Double>(
            size.x / Double(resolution.y),
            size.y / Double(resolution.y),
            size.z / Double(resolution.y)
        )

        //calculate position
        let position: SIMD3<Double> = center ?? SIMD3<Double>(
            Double(resolution.x) / 2,
            Double(resolution.y) / 2,
            Double(resolution.z) / 2
        )
        let relativePosition = SIMD3<Double>(
            (position.x - Double(resolution.x) / 2) / Double(resolution.y),
            (position.y - Double(resolution.y) / 2) / Double(resolution.y),
            (position.z - Double(resolution.z) / 2) / Double(resolution.y)
        )

        //calculate relative corner radius
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)

        //render 3D box
        return try await Renderer.render(
            name: "Box",
            shader: .name("box3d"),
            uniforms: Box3DUniforms(
                premultiply: options.premultiply,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: 0.0,
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

    //function to create surface box
    public static func surfaceBox(size: SIMD3<Double>,
                                  origin: SIMD3<Double>,
                                  cornerRadius: Double = 0.0,
                                  surfaceWidth: Double,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .black,
                                  resolution: SIMD3<Int>,
                                  options: ContentOptions = ContentOptions()) async throws -> Graphic3D {
        //calculate center of box
        let center: SIMD3<Double> = SIMD3<Double>(
            origin.x + size.x / 2,
            origin.y + size.y / 2,
            origin.z + size.z / 2
        )

        //call surface box function with center as input
        return try await surfaceBox(
            size: size,
            center: center,
            cornerRadius: cornerRadius,
            surfaceWidth: surfaceWidth,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }

    //function to create surface box
    public static func surfaceBox(size: SIMD3<Double>,
                                  center: SIMD3<Double>? = nil,
                                  cornerRadius: Double = 0.0,
                                  surfaceWidth: Double,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .black,
                                  resolution: SIMD3<Int>,
                                  options: ContentOptions = ContentOptions()) async throws -> Graphic3D {

        //calculate relative size
        let relativeSize: SIMD3<Double> = SIMD3<Double>(
            size.x / Double(resolution.y),
            size.y / Double(resolution.y),
            size.z / Double(resolution.y)
        )

        //calculate position
        let position: SIMD3<Double> = center ?? SIMD3<Double>(
            Double(resolution.x) / 2,
            Double(resolution.y) / 2,
            Double(resolution.z) / 2
        )
        let relativePosition = SIMD3<Double>(
            (position.x - Double(resolution.x) / 2) / Double(resolution.y),
            (position.y - Double(resolution.y) / 2) / Double(resolution.y),
            (position.z - Double(resolution.z) / 2) / Double(resolution.y)
        )

        //calculate relative corner radius
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)

        //calculate relative surface width
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)

        
                //render surface box
        return try await Renderer.render(
            name: "Box",
            shader: .name("box3d"),
            uniforms: Box3DUniforms(
                premultiply: options.premultiply,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: Float(relativeSurfaceWidth),
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
/* 
The above code is creating two functions to create 3D box and surface box using the Renderer class.
The box(size:origin:cornerRadius:color:backgroundColor:resolution:options:) function creates a 3D box with given
size, origin, corner radius, color, background color, resolution, and options.
The surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:) function creates
a surface box with given size, origin, corner radius, surface width, color, background color, resolution, and options.
Both functions are using the Renderer class to render the 3D box or surface box.
*/
