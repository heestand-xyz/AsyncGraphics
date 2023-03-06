import CoreGraphics
import SwiftUI
import PixelColor

extension AGGraph {
    
    @available(iOS 14, macOS 11, *)
    public func background(_ color: Color) -> any AGGraph {
        AGBackground(graph: self, background: .color(PixelColor(color)))
    }
    
    public func background(_ graph: () -> (any AGGraph)) -> any AGGraph {
        AGBackground(graph: self, background: .graph(graph()))
    }
}

public struct AGBackground: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
     
    let graph: any AGGraph
    
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
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let graphic: Graphic = try await graph.render(at: resolution, details: details)
        let backgroundGraphic: Graphic = try await {
            switch background {
            case .color(let backgroundColor):
                return try await .color(backgroundColor, resolution: resolution)
            case .graph(let backgroundGraph):
                return try await backgroundGraph.render(at: resolution, details: details)
            }
        }()
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over)
    }
}

extension AGBackground: Equatable {

    public static func == (lhs: AGBackground, rhs: AGBackground) -> Bool {
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        guard lhs.background == rhs.background else { return false }
        return true
    }
}

extension AGBackground: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(graph)
        hasher.combine(background)
    }
}
