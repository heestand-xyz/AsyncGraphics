import CoreGraphics
import PixelColor

public struct AGGraphic: AGGraph {
    
    // TODO: Save as a resource with id as key
    let graphic: Graphic
    
    public init(_ graphic: Graphic) {
        self.graphic = graphic
    }
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        graphic.resolution
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        graphic
    }
}

extension AGGraphic: Equatable {
    
    public static func == (lhs: AGGraphic, rhs: AGGraphic) -> Bool {
        lhs.graphic.id == rhs.graphic.id
    }
}

extension AGGraphic: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(graphic.id)
    }
}
