import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GraphicMacro: MemberMacro, MemberAttributeMacro {
    
    static let blackList: [String] = [
        "type",
        "properties"
    ]
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else { return [] }
        let block: MemberBlockSyntax  = classDecl.memberBlock
        var variables: [String] = []
        for member in block.members {
            if let item = member.as(MemberBlockItemSyntax.self)?.decl,
               let variable = item.as(VariableDeclSyntax.self)?.bindings.first,
               let name = variable.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                if blackList.contains(name) {
                    continue
                }
                variables.append(name)
            }
        }
        let erasedVariables: [String] = variables.map { variable in
            "_\(variable).erase()"
        }
        return [
            DeclSyntax(stringLiteral: """
            public var properties: [any AnyGraphicProperty] {
                [
                    \(erasedVariables.joined(separator: ",\n"))
                ]
            }
            """)
        ]
    }
    
    public static func expansion<Declaration, MemberDeclaration, Context>(
        of node: AttributeSyntax,
        attachedTo declaration: Declaration,
        providingAttributesFor member: MemberDeclaration,
        in context: Context
    ) throws -> [AttributeSyntax] where Declaration : DeclGroupSyntax, MemberDeclaration : DeclSyntaxProtocol, Context : MacroExpansionContext {
        
        if let variable = member.as(VariableDeclSyntax.self)?.bindings.first,
           let typeAnnotation = variable.typeAnnotation,
           let name = variable.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
           let identifier = typeAnnotation.type.as(IdentifierTypeSyntax.self) {
            
            let typeName: String = identifier.name.text
            let isMetadata: Bool = typeName == "GraphicMetadata"
            let isEnumMetadata: Bool = typeName == "GraphicEnumMetadata"
            
            if blackList.contains(name) {
                return []
            }
            
            if isMetadata {
                return [
                    AttributeSyntax(stringLiteral: """
                    @GraphicValueProperty(key: "\(name)", name: String(localized: "graphic.property.\(name)"))
                    """)
                ]
            } else if isEnumMetadata {
                return [
                    AttributeSyntax(stringLiteral: """
                    @GraphicEnumProperty(key: "\(name)", name: String(localized: "graphic.property.\(name)"))
                    """)
                ]
            }
        }
        return []
    }
}
