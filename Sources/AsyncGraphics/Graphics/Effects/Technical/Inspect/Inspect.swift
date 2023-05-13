import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct InspectUniforms {
        let transparencyChecker: Bool
        let scale: Float
        let offset: PointUniform
        let borderWidth: Float
        let borderOpacity: Float
        let placement: UInt32
        let scaleRange: SizeUniform
        let resolution: SizeUniform
    }
    
    public static func inspect(scale: CGFloat = 1.0,
                               offset: CGPoint = .zero,
                               borderWidth: CGFloat = 1.0,
                               borderOpacity: CGFloat = 0.25,
                               borderFadeRange: ClosedRange<CGFloat> = 25...50,
                               placement: Placement = .fit,
                               resolution: CGSize,
                               transparencyChecker: Bool = false,
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
                transparencyChecker: transparencyChecker,
                scale: Float(scale),
                offset: offset.uniform,
                borderWidth: Float(borderWidth),
                borderOpacity: Float(borderOpacity),
                placement: placement.index,
                scaleRange: CGSize(width: borderFadeRange.lowerBound,
                                   height: borderFadeRange.upperBound).uniform,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                filter: options.filter
            )
        )
    }
}
