import CoreGraphics

extension AGGraph {
    
    public func luminanceToAlpha() -> any AGGraph {
        AGChannelMix(child: self, red: .luminance, green: .luminance, blue: .luminance, alpha: .luminance)
    }
}

public struct AGChannelMix: AGSingleParentGraph {
    
    var child: any AGGraph
    
    var red: Graphic.ColorChannel = .red
    var green: Graphic.ColorChannel = .green
    var blue: Graphic.ColorChannel = .blue
    var alpha: Graphic.ColorChannel = .alpha
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await child.render(at: resolution, details: details)
            .channelMix(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension AGChannelMix: Equatable {

    public static func == (lhs: AGChannelMix, rhs: AGChannelMix) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.red == rhs.red else { return false }
        guard lhs.green == rhs.green else { return false }
        guard lhs.blue == rhs.blue else { return false }
        guard lhs.alpha == rhs.alpha else { return false }
        return true
    }
}

extension AGChannelMix: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
        hasher.combine(alpha)
    }
}
