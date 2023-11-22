import CoreGraphics

public protocol ContentGraphic2DProtocol: CodableGraphic2DProtocol {
    
    func render(at resolution: CGSize, options: Graphic.ContentOptions) async throws -> Graphic
}
