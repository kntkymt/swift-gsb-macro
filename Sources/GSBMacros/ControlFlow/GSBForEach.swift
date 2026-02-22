import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GSBForEach: GSBControlFlowExpressionMacro {
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

        let arguments = node.arguments.first?.expression
        let values: [[String]] =
            // ["", ""] style
            if let stringArray = arguments?.getAsStringArray() {
                stringArray.map { [$0] }
            }
            // [("", ""), ("", "")] style
            else if let tupleArray = arguments?.getAsTupleArray(),
                let string2DArray = tupleArray.getElementsAsStringArray()
            {
                string2DArray
            }
            else {
                let errorNode: any SyntaxProtocol =
                    node.arguments.first?.expression ?? node.arguments
                throw DiagnosticsError(diagnostics: [
                    GSBMacroDiagnostic
                        .argumentsAcceptOnlyStringLiteral
                        .diagnose(at: errorNode)
                ])
            }

        guard let variableNames = baseClosure.getParameterNames() else {
            throw DiagnosticsError(diagnostics: [
                GSBMacroDiagnostic
                    .shouldUseClosureParameterClause(
                        closure: baseClosure,
                        numberOfArguments: values.first?.count ?? 1
                    )
                    .diagnose(at: baseClosure)
            ])
        }

        // TODO: replace gsb identifiers without break/re-building syntax tree since it costs?
        let baseBody = baseClosure.statements.description
        let content = values.map { tupleValues in
            var body = baseBody
            tupleValues.enumerated().forEach { (index, element) in
                body = body.replacingOccurrences(of: "\\(\(variableNames[index]))", with: element)
            }

            return body
        }.joined(separator: "\n")

        guard let closure = ClosureExprSyntax(ExprSyntax(stringLiteral: "{\(content)}")) else {
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
