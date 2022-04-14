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
    func sample(fraction: Double, axis: Axis = .z) async throws -> Graphic {
        
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
    
    #warning("Axis other than Z failes")
    func samples(axis: Axis = .z) async throws -> [Graphic] {
        
        let count: Int = {
            switch axis {
            case .x:
                return resolution.x
            case .y:
                return resolution.y
            case .z:
                return resolution.z
            }
        }()
        
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
            
            for index in 0..<count {
                group.addTask {
                    let graphic: Graphic = try await self.sample(index: index, axis: axis)
                    return (index, graphic)
                }
            }
            
            var graphics: [(Int, Graphic)] = []
            
            for try await (index, graphic) in group {
                graphics.append((index, graphic))
            }
            
            return graphics
                .sorted(by: { leadingPack, trailingPack in
                    leadingPack.0 < trailingPack.0
                })
                .map(\.1)
        }
        
        return graphics
    }
}
