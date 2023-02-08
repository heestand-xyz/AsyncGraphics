import CoreGraphics

protocol AGGraphDirectEffect: AGGraphEffect {
    var graph: any AGGraph { get }
    func renderDirectEffect(at resolution: CGSize) async throws -> Graphic
}

extension AGGraphDirectEffect {
    public func render(at resolution: CGSize) async throws -> Graphic {
        let resolution = CGSize(width: width ?? resolution.width,
                                height: height ?? resolution.height)
        return try await renderDirectEffect(at: resolution)
    }
}
