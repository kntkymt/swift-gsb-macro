import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct GSBDecl: DeclarationMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let content = try expandGSBBuilderElements(of: node)

        let codeBlockItemList = CodeBlockItemListSyntax(stringLiteral: content).reviseIndent()

        // TODO: (nice-to-have) throw error when stms, expr appears?
        return codeBlockItemList.compactMap {
            guard case .decl(let decl) = $0.item else {
                return nil
            }

            return decl
        }
    }
}
