import CoreGraphics
import CoreGraphicsExtensions

public struct AGNoise: AGGraph {
    
    let offset: CGPoint
    let depth: CGFloat
    let scale: CGFloat
    let octaves: Int
    let seed: Int
    let colored: Bool
    let random: Bool
    
    public init(offset: CGPoint = .zero,
                depth: CGFloat = 0.0,
                scale: CGFloat = 1.0,
                octaves: Int = 1,
                seed: Int = 0,
                colored: Bool = true,
                random: Bool = false) {
        self.offset = offset * .pixelsPerPoint
        self.depth = depth * .pixelsPerPoint
        self.scale = scale
        self.octaves = octaves
        self.seed = seed
        self.colored = colored
        self.random = random
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        if !random {
            if colored {
                return try await .coloredNoise(offset: offset,
                                               depth: depth,
                                               scale: scale,
                                               octaves: octaves,
                                               seed: seed,
                                               resolution: resolution)
            } else {
                return try await .noise(offset: offset,
                                        depth: depth,
                                        scale: scale,
                                        octaves: octaves,
                                        seed: seed,
                                        resolution: resolution)
            }
        } else {
            if colored {
                return try await .randomColoredNoise(seed: seed,
                                                     resolution: resolution)
            } else {
                return try await .randomNoise(seed: seed,
                                              resolution: resolution)
            }
        }
    }
}
