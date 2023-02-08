import CoreGraphics
import PixelColor

extension AGGraph {
    
    public func background(color: PixelColor) -> any AGGraph {
        AGBackground(graph: self, background: .color(color))
    }
    
    public func background(_ graph: () -> (any AGGraph)) -> any AGGraph {
        AGBackground(graph: self, background: .graph(graph()))
    }
}

public struct AGBackground: AGGraphDirectEffect {
    
    let graph: any AGGraph
    
    public var width: CGFloat? { graph.width }
    public var height: CGFloat? { graph.height }
    
    enum Background: Hashable {
        case color(PixelColor)
        case graph(any AGGraph)
        public static func == (lhs: Background, rhs: Background) -> Bool {
            switch lhs {
            case .color(let lhsColor):
                switch rhs {
                case .color(let rhsColor):
                    return lhsColor == rhsColor
                case .graph:
                    return false
                }
            case .graph(let lhsGraph):
                switch rhs {
                case .color:
                    return false
                case .graph(let rhsGraph):
                    return lhsGraph.isEqual(to: rhsGraph)
                }
            }
        }
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .color(let color):
                hasher.combine(color)
            case .graph(let graph):
                hasher.combine(graph)
            }
        }
    }
    let background: Background
    
    public func renderDirectEffect(at resolution: CGSize) async throws -> Graphic {
        let graphic: Graphic = try await graph.render(at: resolution)
        let backgroundGraphic: Graphic = try await {
            switch background {
            case .color(let color):
                return try await .color(color, resolution: resolution)
            case .graph(let graph):
                return try await graph.render(at: resolution)
            }
        }()
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over)
    }
}

extension AGBackground: Equatable {

    public static func == (lhs: AGBackground, rhs: AGBackground) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        guard lhs.background == rhs.background else { return false }
        return true
    }
}

extension AGBackground: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(graph)
        hasher.combine(background)
    }
}
