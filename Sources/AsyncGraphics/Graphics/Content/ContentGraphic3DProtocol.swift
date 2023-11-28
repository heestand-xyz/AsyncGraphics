import Spatial

public protocol ContentGraphic3DProtocol: CodableGraphic3DProtocol {
    
    func render(at resolution: Size3D, options: Graphic3D.ContentOptions) async throws -> Graphic3D
}
