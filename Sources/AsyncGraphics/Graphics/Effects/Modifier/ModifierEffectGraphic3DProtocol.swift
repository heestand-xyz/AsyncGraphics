
public protocol ModifierEffectGraphic3DProtocol: EffectGraphic3DProtocol {
    
    func render(with graphic: Graphic3D, modifier modifierGraphic: Graphic3D, options: Graphic3D.EffectOptions) async throws -> Graphic3D
}
