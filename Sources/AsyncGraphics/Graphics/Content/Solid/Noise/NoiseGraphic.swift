import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public final class Noise: SolidContentGraphicProtocol {
        
        public var octaves: GraphicMetadata<Int> = .init(value: .fixed(1),
                                                         minimum: .fixed(1),
                                                         maximum: .fixed(10))
        
        public var offset: GraphicMetadata<CGPoint> = .init(value: .zero,
                                                            minimum: .resolutionMaximum(fraction: -0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5),
                                                            options: .spatial)
        
        public var depthOffset: GraphicMetadata<CGFloat> = .init(minimum: .resolutionMaximum(fraction: -0.5),
                                                                 maximum: .resolutionMaximum(fraction: 0.5))
        
        public var scale: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public var isRandom: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var isColored: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public var seed: GraphicMetadata<Int> = .init(value: .fixed(0),
                                                      minimum: .fixed(0),
                                                      maximum: .fixed(100))
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
           
            if isRandom.value.eval(at: resolution) {
                
                if isColored.value.eval(at: resolution) {
                    
                   return try await .randomColoredNoise(
                       seed: seed.value.eval(at: resolution),
                       resolution: resolution,
                       options: options)
                    
                } else {
                    
                   return try await .randomNoise(
                       seed: seed.value.eval(at: resolution),
                       resolution: resolution,
                       options: options)
                }
                
            } else {
                
                if isColored.value.eval(at: resolution) {
                    
                   return try await .coloredNoise(
                       offset: offset.value.eval(at: resolution),
                       depth: depthOffset.value.eval(at: resolution),
                       scale: scale.value.eval(at: resolution),
                       octaves: octaves.value.eval(at: resolution),
                       seed: seed.value.eval(at: resolution),
                       resolution: resolution,
                       options: options)
                    
                } else {
             
                    return try await .noise(
                        offset: offset.value.eval(at: resolution),
                        depth: depthOffset.value.eval(at: resolution),
                        scale: scale.value.eval(at: resolution),
                        octaves: octaves.value.eval(at: resolution),
                        seed: seed.value.eval(at: resolution),
                        resolution: resolution,
                        options: options)
                }
            }
        }
        
        public func isVisible(
            property: Property,
            at resolution: CGSize
        ) -> Bool {
        
            switch property {
            case .octaves, .offset, .depthOffset, .scale:
                !isRandom.value.eval(at: resolution)
            default:
                true
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case smooth
            case detailed
            case random
            case smoothColored
            case detailedColored
            case randomColored
        }

        public func edit(variant: Variant) {
            switch variant {
            case .smooth, .detailed, .random:
                isColored.value = .fixed(false)
            case .smoothColored, .detailedColored, .randomColored:
                isColored.value = .fixed(true)
            }
            switch variant {
            case .smooth, .smoothColored:
                octaves.value = .fixed(1)
            case .detailed, .detailedColored:
                octaves.value = .fixed(10)
            case .random, .randomColored:
                isRandom.value = .fixed(true)
            }
        }
    }
}
