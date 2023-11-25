import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct VariantMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
      
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else { return [] }
        
        let block: MemberBlockSyntax  = enumDecl.memberBlock
        
        var enumCases: [String] = []
        for member in block.members {
            guard let item = member.as(MemberBlockItemSyntax.self)?.decl,
                  let enumCase = item.as(EnumCaseDeclSyntax.self)?.elements.first,
                  let name = enumCase.as(EnumCaseElementSyntax.self)?.name.text else {
                continue
            }
            enumCases.append(name)
        }
        
        let comment: String = "..."
        
        let nameCases: [String] = enumCases.map { enumCase in
            """
            case .\(enumCase): String(localized: "variant.\(enumCase)", bundle: .module, comment: "\(comment)")
            """
        }
        
        return [
            DeclSyntax(stringLiteral: """
            public var id: String { rawValue }
            """),
            DeclSyntax(stringLiteral: """
            public var description: String {
                switch self {
                \(nameCases.joined(separator: "\n"))
                }
            }
            """),
        ]
    }
}
