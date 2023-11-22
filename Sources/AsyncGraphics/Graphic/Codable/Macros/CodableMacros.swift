
@attached(member, names: arbitrary)
public macro GraphicTypeMacro() = #externalMacro(module: "AsyncGraphicsMacros", type: "GraphicTypeMacro")

@attached(member, names: arbitrary)
@attached(memberAttribute)
public macro GraphicMacro() = #externalMacro(module: "AsyncGraphicsMacros", type: "GraphicMacro")

@attached(member, names: arbitrary)
public macro EnumMacro() = #externalMacro(module: "AsyncGraphicsMacros", type: "EnumMacro")
