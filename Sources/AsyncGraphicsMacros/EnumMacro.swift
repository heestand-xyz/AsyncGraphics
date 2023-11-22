import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnumMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else { return [] }
        let name = enumDecl.name.text
        let camelName = name.first!.lowercased() + name.dropFirst()
        let block: MemberBlockSyntax  = enumDecl.memberBlock
        var enumCases: [String] = []
        for member in block.members {
            if let item = member.as(MemberBlockItemSyntax.self)?.decl,
               let enumCase = item.as(EnumCaseDeclSyntax.self)?.elements.first,
               let name = enumCase.as(EnumCaseElementSyntax.self)?.name.text {
                enumCases.append(name)
            }
        }
        let switchCases: [String] = enumCases.map { enumCase in
            """
            case .\(enumCase):
                return String(localized: "graphic.enumCase.\(camelName).\(enumCase)")
            """
        }
        return [
            DeclSyntax(stringLiteral: """
            public var id: String { rawValue }
            """),
            DeclSyntax(stringLiteral: """
            public var name: String {
                switch self {
                \(switchCases.joined(separator: "\n"))
                }
            }
            """),
        ]
    }
}
