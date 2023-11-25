import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public final class Blur: DirectEffectGraphicProtocol {
        
        public var style: GraphicEnumMetadata<Graphic.BlurType> = .init(value: .gaussian)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5))
        
        public var position: GraphicMetadata<CGPoint> = .init()
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
           
            switch style.value {
            case .gaussian:
                
                try await graphic.blurred(
                    radius: radius.value.eval(at: graphic.resolution))
                
            case .box:
                
                try await graphic.blurredBox(
                    radius: radius.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .angle:
                
                try await graphic.blurredAngle(
                    radius: radius.value.eval(at: graphic.resolution),
                    angle: rotation.value.eval(at: graphic.resolution),
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
            case .rotation:
                style.value == .angle
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
