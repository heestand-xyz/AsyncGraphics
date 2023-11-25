import CoreGraphics

extension CodableGraphic3D.Effect.Direct {
    
    @GraphicMacro
    public final class Blur: DirectEffectGraphic3DProtocol {
        
        public var style: GraphicEnumMetadata<Graphic3D.Blur3DType> = .init(value: .box)

        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5))
        
        public var position: GraphicMetadata<SIMD3<Double>> = .init()
        
        public var direction: GraphicMetadata<SIMD3<Double>> = .init(value: .fixed(SIMD3<Double>(1.0, 0.0, 0.0)),
                                                                     minimum: .fixed(SIMD3<Double>(-1.0, -1.0, -1.0)),
                                                                     maximum: .fixed(SIMD3<Double>(1.0, 1.0, 1.0)))
                
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(10),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(10))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
           
            switch style.value {
            case .box:
                
                try await graphic.blurredBox(
                    radius: radius.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .direction:
                
                try await graphic.blurredDirection(
                    radius: radius.value.eval(at: graphic.resolution),
                    direction: direction.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .zoom:
                
                try await graphic.blurredZoom(
                    radius: radius.value.eval(at: graphic.resolution),
                    center: position.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .random:
                
                try await graphic.blurredRandom(
                    radius: radius.value.eval(at: graphic.resolution),
                    options: options)
            }
        }
        
        public func isVisible(property: Property, at resolution: CGSize) -> Bool {
            switch property {
            case .style:
                true
            case .radius:
                true
            case .position:
                style.value == .zoom
            case .direction:
                style.value == .direction
            case .sampleCount:
                style.value != .random
            }
        }
        
        @VariantMacro
        enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            }
        }
    }
}
