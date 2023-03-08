
@resultBuilder
public struct AGGraphBuilder {
    static func buildBlock() -> [any AGGraph] { [] }
}

public extension AGGraphBuilder {
    static func buildBlock(_ graphics: (any AGGraph)...) -> [any AGGraph] {
        graphics
    }
}
