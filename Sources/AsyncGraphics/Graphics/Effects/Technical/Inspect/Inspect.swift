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
    
    static func inspect(scale: CGFloat = 1.0,
                        offset: CGPoint = .zero,
                        borderWidth: CGFloat = 1.0,
                        borderColor: PixelColor = .gray,
                        placement: Placement = .fit,
                        resolution: CGSize,
                        graphic: () async throws -> Graphic) async throws -> Graphic {
        
        try await Renderer.render(
            name: "inspect",
            shader: .name("inspect"),
            uniforms: InspectUniforms(
                scale: Float(scale),
                offset: offset.uniform,
                borderWidth: Float(borderWidth),
                borderColor: borderColor.uniform,
                placement: placement.index,
                resolution: resolution.uniform
            )
        )
    }
}
