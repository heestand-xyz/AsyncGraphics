//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic {
    
    private struct LookupUniforms: Uniforms {
        let axis: UInt32
        let holdEdge: Bool
        let holdEdgeFraction: Float
        let sampleCoordinate: Float
    }
    
    @EnumMacro
    public enum LookupAxis: String, GraphicEnum {
        case horizontal
        case vertical
    }
    
    public func lookup(
        with graphic: Graphic,
        axis: LookupAxis,
        sampleCoordinate: CGFloat = 0.5,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
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
                graphic
            ],
            uniforms: LookupUniforms(
                axis: axis.index,
                holdEdge: true,
                holdEdgeFraction: Float(holdEdgeFraction),
                sampleCoordinate: Float(sampleCoordinate)
            ),
            options: options.spatialRenderOptions
        )
    }
}
