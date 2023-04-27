//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic {
    
    private struct LookupUniforms {
        let axis: UInt32
        let holdEdge: Bool
        let holdEdgeFraction: Float
        let sampleCoordinate: Float
    }
    
    public enum LookupAxis: UInt32 {
        case horizontal = 0
        case vertical = 1
    }
    
    @available(*, deprecated, renamed: "lookup(axis:sampleCoordinate:options:graphic:)")
    public func lookup(with graphic: Graphic,
                       axis: LookupAxis,
                       sampleCoordinate: CGFloat = 0.5,
                       options: EffectOptions = EffectOptions()) async throws -> Graphic {
        try await lookup(axis: axis, sampleCoordinate: sampleCoordinate, options: options) {
            graphic
        }
    }
    
    public func lookup(axis: LookupAxis,
                       sampleCoordinate: CGFloat = 0.5,
                       options: EffectOptions = EffectOptions(),
                       graphic: () async throws -> Graphic) async throws -> Graphic {
            
        let holdEdgeFraction: CGFloat = {
            switch axis {
            case .horizontal:
                return 1.0 / resolution.width
            case .vertical:
                return 1.0 / resolution.height
            }
        }()
        
        return try await Renderer.render(
            name: "Lookup",
            shader: .name("lookup"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: LookupUniforms(
                axis: axis.rawValue,
                holdEdge: true,
                holdEdgeFraction: Float(holdEdgeFraction),
                sampleCoordinate: Float(sampleCoordinate)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
