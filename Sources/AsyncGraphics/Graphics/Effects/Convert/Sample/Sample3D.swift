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
    
    public struct SampleProgress {
        public let index: Int
        public let count: Int
        public var fraction: CGFloat {
            CGFloat(index) / CGFloat(count - 1)
        }
        class Manager {
            private let count: Int
            private var index: Int = 0
            private let progress: (SampleProgress) -> ()
            init(count: Int, progress: @escaping (SampleProgress) -> ()) {
                self.count = count
                self.progress = progress
            }
            func increment() {
                progress(SampleProgress(index: index, count: count))
                index += 1
            }
        }
    }
    
    public func samples(/*axis: Axis = .z*/progress: ((SampleProgress) -> ())? = nil) async throws -> [Graphic] {
        
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
        
        let progressManager: SampleProgress.Manager? = if let progress {
            SampleProgress.Manager(count: count, progress: progress)
        } else { nil }
        
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
            
            for index in 0..<count {
                group.addTask {
                    let graphic: Graphic = try await self.sample(index: index/*, axis: axis*/)
                    progressManager?.increment()
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
