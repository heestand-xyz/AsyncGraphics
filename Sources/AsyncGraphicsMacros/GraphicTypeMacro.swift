import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GraphicTypeMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
      
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else { return [] }
        
        let rawName = enumDecl.name.text
        
        let is3D: Bool = rawName.contains("3D")
        
        let typeName: String = rawName
            .replacingOccurrences(of: "GraphicType", with: "")
            .replacingOccurrences(of: "Graphic3DType", with: "")
        
        let spaceName: String = typeName.reduce("", {
            guard "\($1)".uppercased() == "\($1)",
                  $0.count > 0
            else { return $0 + String($1) }
            return ($0 + " " + String($1))
        })
        
        let dotName = spaceName
            .split(separator: " ")
            .map(String.init)
            .reversed()
            .joined(separator: ".")

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
            case .\(enumCase): String(localized: "graphic.type.\(enumCase)", comment: "\(spaceName)")
            """
        }
        
        let typeCases: [String] = enumCases.map { enumCase in
            let caseName = enumCase.first!.uppercased() + enumCase.dropFirst()
            return """
            case .\(enumCase): CodableGraphic\(is3D ? "3D" : "").\(dotName).\(caseName).self
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
            public var type: \(typeName)Graphic\(is3D ? "3D" : "")Protocol.Type {
                switch self {
                \(typeCases.joined(separator: "\n"))
                }
            }
            """),
        ]
    }
}
