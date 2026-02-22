import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct GSBIf: GSBControlFlowExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        let content = try stringExpansion(of: node)
        let stringLiteral = StringLiteralExprSyntax.multiline(content: content)

        return ExprSyntax(stringLiteral)
    }

    public static func stringExpansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax
    ) throws -> String {
        guard let variable = node.arguments.first?.expression.getAsString() else {
            let errorNode: any SyntaxProtocol = node.arguments.first?.expression ?? node.arguments
            throw DiagnosticsError(diagnostics: [
                GSBMacroDiagnostic
                    .argumentsAcceptOnlyStringLiteral
                    .diagnose(at: errorNode)
            ])
        }

        let value =
            if let string = node.arguments.last?.expression.getAsString() {
                [string]
            }
            else if let array = node.arguments.last?.expression.getAsStringArray() {
                array
            }
            else {
                let errorNode: any SyntaxProtocol =
                    node.arguments.last?.expression ?? node.arguments
                throw DiagnosticsError(diagnostics: [
                    GSBMacroDiagnostic
                        .argumentsAcceptOnlyStringLiteral
                        .diagnose(at: errorNode)
                ])
            }

        let condition =
            switch node.arguments.last?.label?.text {
            case "equalsTo", "in": value.contains { $0 == variable }
            case "notEqualsTo", "notIn": !value.contains { $0 == variable }
            default: preconditionFailure("unexpected gsbIf overload")
            }

        guard condition else { return "" }

        return try expandGSBBuilderElements(of: node)
    }
}
