
public protocol ModifierEffectGraphicProtocol: EffectGraphicProtocol {
    
    func render(with graphic: Graphic, modifier modifierGraphic: Graphic, options: Graphic.EffectOptions) async throws -> Graphic
}
