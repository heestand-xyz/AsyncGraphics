import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class Blur: SpaceEffectGraphicProtocol {
        
        public var docs: String {
            "Blur a graphic. Gaussian blur is the fastest."
        }
        
        public var tags: [String] {
            Graphic.BlurType.allCases.map(\.name)
        }
        
        public var style: GraphicEnumMetadata<Graphic.BlurType> = .init(value: .gaussian)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5),
                                                            options: .spatial)
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public var layerCount: GraphicMetadata<Int> = .init(value: .fixed(10),
                                                            minimum: .fixed(1),
                                                            maximum: .fixed(10))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
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
                    position: position.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .random:
                
                try await graphic.blurredRandom(
                    radius: radius.value.eval(at: graphic.resolution),
                    options: options)
                
            case .layered:
                
                try await graphic.blurredLayered(
                    radius: radius.value.eval(at: graphic.resolution),
                    layerCount: layerCount.value.eval(at: graphic.resolution),
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
            case .layerCount:
                style.value == .layered
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case light
            case medium
            case heavy
            case angle
            case zoom
            case random
        }

        public func edit(variant: Variant) {
            switch variant {
            case .light, .medium, .heavy:
                style.value = .gaussian
            case .angle:
                style.value = .angle
            case .zoom:
                style.value = .zoom
            case .random:
                style.value = .random
            }
            switch variant {
            case .light:
                radius.value = .resolutionMinimum(fraction: 1.0 / 32)
            case .medium:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .heavy:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .angle:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .zoom:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .random:
                break
            }
        }
    }
}
