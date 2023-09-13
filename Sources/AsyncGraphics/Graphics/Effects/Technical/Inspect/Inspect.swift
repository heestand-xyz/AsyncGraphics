import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct InspectUniforms {
        let checkerTransparency: Bool
        let checkerSize: Float
        let checkerOpacity: Float
        let scale: Float
        let offset: PointUniform
        let borderWidth: Float
        let borderOpacity: Float
        let placement: UInt32
        let scaleRange: SizeUniform
        let containerResolution: SizeUniform
        let contentResolution: SizeUniform
    }
    
    public static func inspect(scale: CGFloat = 1.0,
                               offset: CGPoint = .zero,
                               borderWidth: CGFloat = 1.0,
                               borderOpacity: CGFloat = 0.25,
                               borderFadeRange: ClosedRange<CGFloat> = 25...50,
                               placement: Placement = .fit,
                               containerResolution: CGSize,
                               contentResolution: CGSize,
                               checkerTransparency: Bool = false,
                               checkerSize: CGFloat = 100,
                               checkerOpacity: CGFloat = 0.5,
                               options: ContentOptions = .interpolateNearest,
                               graphic: () async throws -> Graphic) async throws -> Graphic {
        
        let graphic: Graphic = try await graphic()
        
        return try await Renderer.render(
            name: "inspect",
            shader: .name("inspect"),
            graphics: [
                graphic
            ],
            uniforms: InspectUniforms(
                checkerTransparency: checkerTransparency,
                checkerSize: Float(checkerSize),
                checkerOpacity: Float(checkerOpacity),
                scale: Float(scale),
                offset: offset.uniform,
                borderWidth: Float(borderWidth),
                borderOpacity: Float(borderOpacity),
                placement: placement.index,
                scaleRange: CGSize(width: borderFadeRange.lowerBound,
                                   height: borderFadeRange.upperBound).uniform,
                containerResolution: containerResolution.uniform,
                contentResolution: contentResolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: containerResolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                filter: options.filter
            )
        )
    }
}
