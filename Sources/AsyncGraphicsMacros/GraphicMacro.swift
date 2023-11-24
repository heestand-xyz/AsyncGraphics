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
        
        var is3D: Bool = false
        
        let block: MemberBlockSyntax  = classDecl.memberBlock
        
        var variables: [String] = []
        for member in block.members {
            guard let item = member.as(MemberBlockItemSyntax.self)?.decl,
                  let variable = item.as(VariableDeclSyntax.self)?.bindings.first,
                  let id = variable.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }
            let name = id.identifier.text
            if name == "type" {
                if let typeName = variable.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name.text {
                    is3D = typeName.contains("3D")
                }
            }
            if blackList.contains(name) {
                continue
            }
            variables.append(name)
        }
        
        let erasedVariables: [String] = variables.map { variable in
            "_\(variable).erase()"
        }
        
        let enumVariables: [String] = variables.map { variable in
            "case \(variable)"
        }
        
        return [
            DeclSyntax(stringLiteral: """
            public var properties: [any AnyGraphicProperty] {
                [
                    \(erasedVariables.joined(separator: ",\n"))
                ]
            }
            """),
            DeclSyntax(stringLiteral: """
            enum Property: String, GraphicPropertyType {
                \(enumVariables.joined(separator: "\n"))
            }
            """),
            DeclSyntax(stringLiteral: """
            func isVisible(propertyKey: String, at resolution: \(is3D ? "SIMD3<Int>" : "CGSize")) -> Bool? {
                guard let property = Property.allCases.first(where: { $0.rawValue == propertyKey }) else { return nil }
                return isVisible(property: property, at: resolution)
            }
            """),
        ]
    }
    
    public static func expansion<Declaration, MemberDeclaration, Context>(
        of node: AttributeSyntax,
        attachedTo declaration: Declaration,
        providingAttributesFor member: MemberDeclaration,
        in context: Context
    ) throws -> [AttributeSyntax] where Declaration : DeclGroupSyntax, MemberDeclaration : DeclSyntaxProtocol, Context : MacroExpansionContext {
        
        guard let className = declaration.as(ClassDeclSyntax.self)?.name.text,
              let variable = member.as(VariableDeclSyntax.self)?.bindings.first,
              let typeAnnotation = variable.typeAnnotation,
              let name = variable.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let identifier = typeAnnotation.type.as(IdentifierTypeSyntax.self) else {
            return []
        }
        
        let typeName: String = identifier.name.text
        let isMetadata: Bool = typeName == "GraphicMetadata"
        let isEnumMetadata: Bool = typeName == "GraphicEnumMetadata"
        
        if blackList.contains(name) {
            return []
        }
        
        let localizedName = """
        String(localized: "property.\(name)", bundle: .module, comment: "\(className)")
        """
        
        if isMetadata {
            return [
                AttributeSyntax(stringLiteral: """
                @GraphicValueProperty(key: "\(name)", name: \(localizedName))
                """)
            ]
        } else if isEnumMetadata {
            return [
                AttributeSyntax(stringLiteral: """
                @GraphicEnumProperty(key: "\(name)", name: \(localizedName))
                """)
            ]
        } else {
            return []
        }
    }
}
