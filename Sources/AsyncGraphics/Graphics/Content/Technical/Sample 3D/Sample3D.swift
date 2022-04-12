//
//  Created by Anton Heestand on 2022-04-11.
//

import Foundation
import TextureMap

public extension Graphic3D {
    
    /// Sample
    ///
    /// Fraction 0.0 is the first plane
    ///
    /// Fraction 1.0 is the last plane
    func sample(fraction: Double, axis: Axis) async throws -> Graphic {
        
        let index: Int = {
            switch axis {
            case .x:
                return Int(round(fraction * Double(resolution.x - 1)))
            case .y:
                return Int(round(fraction * Double(resolution.y - 1)))
            case .z:
                return Int(round(fraction * Double(resolution.z - 1)))
            }
        }()
        
        return try await sample(index: index, axis: axis)
    }
    
    #warning("Axis other than Z failes")
    func sample(index: Int, axis: Axis = .z) async throws -> Graphic {
        
        let texture = try await texture.sample3d(index: index, axis: axis.tmAxis, bits: bits)
        
        return Graphic(name: "Sample", texture: texture, bits: bits, colorSpace: colorSpace)
    }
}
