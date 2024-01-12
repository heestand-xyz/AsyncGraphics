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
        
        let name: String = classDecl.name.text
        
        let rawTypeName: String = classDecl.inheritanceClause?.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self)?.name.text ?? ""
        
        let typeName: String = rawTypeName
            .replacingOccurrences(of: "GraphicProtocol", with: "")
            .replacingOccurrences(of: "Graphic3DProtocol", with: "")
        
        let names: [String] = typeName
            .reduce("", {
                guard "\($1)".uppercased() == "\($1)",
                      $0.count > 0
                else { return $0 + String($1) }
                return ($0 + " " + String($1))
            })
            .split(separator: " ")
            .map(String.init)

        let parentName = names.first ?? ""
        let grandParentName = names.last ?? ""
        
        let is3D: Bool = rawTypeName.contains("3D")
        
        let block: MemberBlockSyntax  = classDecl.memberBlock
        
        var variables: [String] = []
        for member in block.members {
            guard let item = member.as(MemberBlockItemSyntax.self)?.decl,
                  let variable = item.as(VariableDeclSyntax.self)?.bindings.first,
                  let id = variable.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }
            let name = id.identifier.text
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
        
        func camel(_ name: String) -> String {
            name.first!.lowercased() + name.dropFirst()
        }
        
        return [
            DeclSyntax(stringLiteral: """
            public static var type: CodableGraphic\(is3D ? "3D" : "")Type {
                .\(camel(grandParentName))(.\(camel(parentName))(.\(camel(name))))
            }
            """),
            DeclSyntax(stringLiteral: """
            public var properties: [any AnyGraphicProperty] {
                [
                    \(erasedVariables.joined(separator: ",\n"))
                ]
            }
            """),
            DeclSyntax(stringLiteral: """
            public enum Property: String, GraphicPropertyType {
                \(enumVariables.joined(separator: "\n"))
            }
            """),
            DeclSyntax(stringLiteral: """
            public func isVisible(propertyKey: String, at resolution: \(is3D ? "Size3D" : "CGSize")) -> Bool? {
                guard let property = Property.allCases.first(where: { $0.rawValue == propertyKey }) else { return nil }
                return isVisible(property: property, at: resolution)
            }
            """),
            DeclSyntax(stringLiteral: """
            public static func variantIDs() -> [GraphicVariantID] {
                Variant.allCases.map { variant in
                    GraphicVariantID(
                        key: variant.rawValue,
                        description: variant.description
                    )
                }
            }
            """),
            DeclSyntax(stringLiteral: """
            public func edit(variantKey: String) {
                guard let variant = Variant.allCases.first(where: {
                        $0.rawValue == variantKey
                    }) else {
                    return
                }
                return edit(variant: variant)
            }
            """),
            DeclSyntax(stringLiteral: """
            public required init() {}
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
        String(localized: "property.\(name)", bundle: .module)
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
