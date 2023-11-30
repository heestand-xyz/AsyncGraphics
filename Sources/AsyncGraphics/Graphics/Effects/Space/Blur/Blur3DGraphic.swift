import Spatial
import CoreGraphics

extension CodableGraphic3D.Effect.Direct {
    
    @GraphicMacro
    public final class Blur: DirectEffectGraphic3DProtocol {
        
        public var style: GraphicEnumMetadata<Graphic3D.Blur3DType> = .init(value: .box)

        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5))
        
        public var position: GraphicMetadata<Point3D> = .init()
        
        public var direction: GraphicMetadata<Point3D> = .init(value: .fixed(Point3D(x: 1.0, y: 0.0, z: 0.0)),
                                                               minimum: .fixed(Point3D(x: -1.0, y: -1.0, z: -1.0)),
                                                               maximum: .fixed(Point3D(x: 1.0, y: 1.0, z: 1.0)))
                
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(10),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(10))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = [.edgeStretch]
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
                    position: position.value.eval(at: graphic.resolution),
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
        public enum Variant: String, GraphicVariant {
            case light
            case medium
            case heavy
            case zoom
            case random
        }

        public func edit(variant: Variant) {
            switch variant {
            case .light, .medium, .heavy:
                style.value = .box
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
            case .zoom:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .random:
                break
            }
        }
    }
}
