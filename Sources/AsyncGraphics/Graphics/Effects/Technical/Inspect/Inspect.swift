import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct InspectUniforms {
        let scale: Float
        let offset: PointUniform
        let borderWidth: Float
        let borderColor: ColorUniform
        let placement: UInt32
        let resolution: SizeUniform
    }
    
    public static func inspect(scale: CGFloat = 1.0,
                               offset: CGPoint = .zero,
                               borderWidth: CGFloat = 1.0,
                               borderColor: PixelColor = .gray,
                               placement: Placement = .fit,
                               resolution: CGSize,
                               interpolateNearest: Bool = true,
                               options: ContentOptions = [],
                               graphic: () async throws -> Graphic) async throws -> Graphic {
        
        let graphic: Graphic = try await graphic()
        
        return try await Renderer.render(
            name: "inspect",
            shader: .name("inspect"),
            graphics: [
                graphic
            ],
            uniforms: InspectUniforms(
                scale: Float(scale),
                offset: offset.uniform,
                borderWidth: Float(borderWidth),
                borderColor: borderColor.uniform,
                placement: placement.index,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                filter: interpolateNearest ? .nearest : .linear
            )
        )
    }
}
