
public protocol SpaceEffectGraphicProtocol: EffectGraphicProtocol {
    
    func render(with graphic: Graphic, options: Graphic.EffectOptions) async throws -> Graphic
}
