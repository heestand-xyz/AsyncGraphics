import CoreGraphics

extension AGGraph {
    
    public func luminanceToAlpha() -> any AGGraph {
        AGChannelMix(graph: self, red: .mono, green: .mono, blue: .mono, alpha: .mono)
    }
}

public struct AGChannelMix: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    var red: Graphic.ColorChannel = .red
    var green: Graphic.ColorChannel = .green
    var blue: Graphic.ColorChannel = .blue
    var alpha: Graphic.ColorChannel = .alpha
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await graph.render(at: resolution, details: details)
            .channelMix(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension AGChannelMix: Equatable {

    public static func == (lhs: AGChannelMix, rhs: AGChannelMix) -> Bool {
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        guard lhs.red == rhs.red else { return false }
        guard lhs.green == rhs.green else { return false }
        guard lhs.blue == rhs.blue else { return false }
        guard lhs.alpha == rhs.alpha else { return false }
        return true
    }
}

extension AGChannelMix: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(graph)
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
        hasher.combine(alpha)
    }
}
