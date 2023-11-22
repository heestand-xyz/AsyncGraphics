import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Solid {
    
    @GraphicMacro
    public class Gradient: SolidGraphic3DProtocol {
        
        public var type: CodableGraphic3DType {
            .content(.solid(.gradient))
        }
        
        public var direction: GraphicEnumMetadata<Graphic3D.Gradient3DDirection> = .init(value: .y)
        
        public var stops: GraphicMetadata<[Graphic.GradientStop]> = .init(value: .fixed([
            Graphic.GradientStop(at: 0.0, color: .black),
            Graphic.GradientStop(at: 1.0, color: .white),
        ]))
        
        public var position: GraphicMetadata<SIMD3<Double>> = .init()
        
        public var scale: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .fixed(0.0),
                                                            minimum: .fixed(-1.0))
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var extend: GraphicEnumMetadata<Graphic.GradientExtend> = .init(value: .zero)
        public required init() {}
        
        public func render(
            at resolution: SIMD3<Int>,
            options: Graphic3D.ContentOptions
        ) async throws -> Graphic3D {

            try await .gradient(
                direction: direction.value,
                stops: stops.value.at(resolution: resolution),
                center: position.value.at(resolution: resolution),
                scale: scale.value.at(resolution: resolution),
                offset: offset.value.at(resolution: resolution),
                extend: extend.value,
                gamma: gamma.value.at(resolution: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
