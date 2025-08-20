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
        
        let rawName = enumDecl.name.text
        let rawCamelCaseName = rawName.first!.lowercased() + rawName.dropFirst()
        
        let block: MemberBlockSyntax  = enumDecl.memberBlock
        
        var enumCases: [String] = []
        for member in block.members {
            guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self)?.elements.first else {
                continue
            }
            let name: String = enumCase.name.text
            enumCases.append(name)
        }
        
        let nameCases: [String] = enumCases.map { enumCase in
            """
            case .\(enumCase): String(localized: "option.\(rawCamelCaseName).\(enumCase)", bundle: .module)
            """
        }
        
        let indexCases: [String] = enumCases.enumerated().map { index, enumCase in
            """
            case .\(enumCase): \(index)
            """
        }
        
        return [
            DeclSyntax(stringLiteral: """
            public var id: String { rawValue }
            """),
            DeclSyntax(stringLiteral: """
            public var name: String {
                switch self {
                \(nameCases.joined(separator: "\n"))
                }
            }
            """),
            DeclSyntax(stringLiteral: """
            public var index: UInt32 {
                switch self {
                \(indexCases.joined(separator: "\n"))
                }
            }
            """),
        ]
    }
}
