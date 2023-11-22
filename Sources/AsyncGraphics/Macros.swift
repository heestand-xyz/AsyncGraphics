import AsyncGraphicsMacros

@attached(member, names: arbitrary)
@attached(memberAttribute)
public macro GraphicMacro() = #externalMacro(module: "AsyncGraphicsMacros", type: "GraphicMacro")

