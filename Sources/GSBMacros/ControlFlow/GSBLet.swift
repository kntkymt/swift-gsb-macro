import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct GSBLet: GSBControlFlowExpressionMacro {
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
        let baseClosure = try requireTrailingClosure(of: node)
        guard let value = node.arguments.first?.expression.getAsString() else {
            let errorNode: any SyntaxProtocol = node.arguments.first?.expression ?? node.arguments
            throw DiagnosticsError(diagnostics: [
                GSBMacroDiagnostic
                    .argumentsAcceptOnlyStringLiteral
                    .diagnose(at: errorNode)
            ])
        }

        guard let variableName = baseClosure.getParameterNames()?.first else {
            throw DiagnosticsError(diagnostics: [
                GSBMacroDiagnostic
                    .shouldUseClosureParameterClause(closure: baseClosure, numberOfArguments: 1)
                    .diagnose(at: baseClosure)
            ])
        }

        // TODO: replace gsb identifiers without break/re-building syntax tree since it costs?
        let baseBody = baseClosure.description
        let content = baseBody.replacingOccurrences(of: "\\(\(variableName))", with: value)
        guard let closure = ClosureExprSyntax(ExprSyntax(stringLiteral: content)) else {
            throw DiagnosticsError(diagnostics: [
                GSBMacroDiagnostic
                    .invalidSyntaxOnBuilderExprAfterReplacingVariables
                    .diagnose(at: node)
            ])
        }
        let expandedContent = try expandGSBBuilderElements(of: closure)

        return expandedContent
    }
}
