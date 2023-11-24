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
        
        let names: [String] = rawName
            .reduce("", {
                guard "\($1)".uppercased() == "\($1)",
                      $0.count > 0
                else { return $0 + String($1) }
                return ($0 + " " + String($1))
            })
            .split(separator: " ")
            .map(String.init)
                
        let spaceName = names
            .joined(separator: " ")
        
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
        
        let nameCases: [String] = enumCases.map { enumCase in
            """
            case .\(enumCase): String(localized: "option.\(enumCase)", bundle: .module, comment: "\(spaceName)")
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
