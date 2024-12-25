public struct AGComponents: Sendable {
    var blendMode: Graphic.BlendMode?
}

extension AGComponents {
    static let `default` = AGComponents(blendMode: nil)
}
