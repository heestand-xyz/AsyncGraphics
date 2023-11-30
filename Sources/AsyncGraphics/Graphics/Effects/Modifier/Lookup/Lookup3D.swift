//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic3D {
    
    private struct Lookup3DUniforms {
        let axis: UInt32
        let holdEdge: Bool
        let holdEdgeFraction: Float
        let sampleCoordinate: Float
    }
    
    public enum Lookup3DAxis: UInt32 {
        case x
        case y
        case z
    }
    
    public func lookup(with graphic: Graphic3D,
                       axis: Lookup3DAxis,
                       sampleCoordinate: CGFloat = 0.5,
                       options: EffectOptions = []) async throws -> Graphic3D {
        
        let holdEdgeFraction: CGFloat = {
            switch axis {
            case .x:
                return 1.0 / width
            case .y:
                return 1.0 / height
            case .z:
                return 1.0 / depth
            }
        }()
        
        return try await Renderer.render(
            name: "Lookup 3D",
            shader: .name("lookup3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: Lookup3DUniforms(
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
