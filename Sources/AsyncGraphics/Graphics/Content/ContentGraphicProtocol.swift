import CoreGraphics

public protocol ContentGraphicProtocol: CodableGraphicProtocol {
    
    func render(at resolution: CGSize, options: Graphic.ContentOptions) async throws -> Graphic
}
