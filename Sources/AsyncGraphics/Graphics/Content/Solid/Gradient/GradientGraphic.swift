import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public class Gradient: SolidGraphicProtocol {
        
        public var type: CodableGraphicType {
            .content(.solid(.gradient))
        }
        
        public var direction: GraphicEnumMetadata<Graphic.GradientDirection> = .init(value: .vertical)
        
        public var colorStops: GraphicMetadata<[Graphic.GradientStop]> = .init(value: .fixed([
            Graphic.GradientStop(at: 0.0, color: .black),
            Graphic.GradientStop(at: 1.0, color: .white),
        ]))
        
        public var position: GraphicMetadata<CGPoint> = .init()
        
        public var scale: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .fixed(0.0),
                                                            minimum: .fixed(-1.0))
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var extend: GraphicEnumMetadata<Graphic.GradientExtend> = .init(value: .zero)
        public required init() {}
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            try await .gradient(
                direction: direction.value,
                stops: colorStops.value.eval(at: resolution),
                center: position.value.eval(at: resolution),
                scale: scale.value.eval(at: resolution),
                offset: offset.value.eval(at: resolution),
                extend: extend.value,
                gamma: gamma.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
