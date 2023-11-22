import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AsyncGraphicsMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GraphicTypeMacro.self,
        GraphicMacro.self,
        EnumMacro.self,
    ]
}
