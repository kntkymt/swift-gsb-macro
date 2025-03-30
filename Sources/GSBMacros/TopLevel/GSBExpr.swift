import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GSBExpr: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        let content = try expandGSBBuilderElements(of: node)

        return ExprSyntax(stringLiteral: "{\(content)}()")
    }
}
