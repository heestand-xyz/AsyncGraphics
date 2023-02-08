
@resultBuilder
public struct AGResultBuilder {
    static func buildBlock() -> [any AGGraph] { [] }
}

public extension AGResultBuilder {
    static func buildBlock(_ graphics: (any AGGraph)...) -> [any AGGraph] {
        graphics
    }
}
// Result builder 'AGResultBuilder' does not implement any 'buildBlock' or a combination of 'buildPartialBlock(first:)' and 'buildPartialBlock(accumulated:next:)' with sufficient availability for this call site
