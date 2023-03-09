
@resultBuilder
public struct AGGraphBuilder {
    static func buildBlock() -> [any AGGraph] { [] }
}

public extension AGGraphBuilder {
    
    static func buildBlock(_ graphs: (any AGGraph)...) -> [any AGGraph] {
        graphs
    }
    
    static func buildBlock(_ graphs: [any AGGraph]) -> [any AGGraph] {
        graphs
    }
    
    static func buildEither(first graphs: [any AGGraph]) -> [any AGGraph] {
        graphs
    }
    
    static func buildEither(second graphs: [any AGGraph]) -> [any AGGraph] {
        graphs
    }
}
