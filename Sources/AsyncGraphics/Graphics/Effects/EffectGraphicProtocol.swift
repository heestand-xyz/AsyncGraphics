import CoreGraphics

public protocol EffectGraphicProtocol: CodableGraphicProtocol {
    
    func render(with graphic: Graphic, options: Graphic.EffectOptions) async throws -> Graphic
}
