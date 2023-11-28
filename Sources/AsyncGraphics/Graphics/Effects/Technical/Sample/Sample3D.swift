//
//  Created by Anton Heestand on 2022-04-11.
//

import Foundation
import TextureMap

extension Graphic3D {
    
    /// Sample
    ///
    /// Fraction 0.0 is the first plane
    ///
    /// Fraction 1.0 is the last plane
    public func sample(fraction: Double/*, axis: Axis = .z*/) async throws -> Graphic {
        
        let axis: Axis = .z
        
        let index: Int = {
            switch axis {
            case .x:
                return Int(round(fraction * resolution.width - 1.0))
            case .y:
                return Int(round(fraction * resolution.height - 1.0))
            case .z:
                return Int(round(fraction * resolution.depth - 1.0))
            }
        }()
        
        return try await sample(index: index/*, axis: axis*/)
    }
    
    public func sample(index: Int/*, axis: Axis = .z*/) async throws -> Graphic {
        
        let axis: Axis = .z
        
        let texture = try await texture.sample3d(index: index, axis: axis.tmAxis, bits: bits)
        
        return Graphic(name: "Sample", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
    public func samples(/*axis: Axis = .z*/) async throws -> [Graphic] {
        
        let axis: Axis = .z
        
        let count: Int = {
            switch axis {
            case .x:
                return Int(resolution.width)
            case .y:
                return Int(resolution.height)
            case .z:
                return Int(resolution.depth)
            }
        }()
        
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
            
            for index in 0..<count {
                group.addTask {
                    let graphic: Graphic = try await self.sample(index: index/*, axis: axis*/)
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
