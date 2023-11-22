import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AsyncGraphicsMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GraphicMacro.self,
        EnumMacro.self,
    ]
}
