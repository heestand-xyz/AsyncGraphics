import simd

public protocol ContentGraphic3DProtocol: CodableGraphic3DProtocol {
    
    func render(at resolution: SIMD3<Int>, options: Graphic3D.ContentOptions) async throws -> Graphic3D
}
