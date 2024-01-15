
public protocol ColorEffectGraphicProtocol: EffectGraphicProtocol {
    
    func render(with graphic: Graphic, options: Graphic.EffectOptions) async throws -> Graphic
}
