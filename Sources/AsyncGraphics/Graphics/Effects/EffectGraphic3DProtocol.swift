import Spatial

public protocol EffectGraphic3DProtocol: CodableGraphic3DProtocol {
    
    func render(with graphic: Graphic3D, options: Graphic3D.EffectOptions) async throws -> Graphic3D
}
