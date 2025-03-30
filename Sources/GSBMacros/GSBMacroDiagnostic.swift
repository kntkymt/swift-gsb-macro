import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum GSBMacroDiagnostic {
    case shouldUseTrailingClosure(FreestandingMacroExpansionSyntax)
    case shouldUseClosureParameterClause(closure: ClosureExprSyntax, numberOfArguments: Int)
    case builderAcceptsOnlyStringLiteralOrGSBMacroExpansion
    case argumentsAcceptOnlyStringLiteral
    case invalidSyntaxOnBuilderExprAfterReplacingVariables
}

extension GSBMacroDiagnostic: DiagnosticMessage {
    var message: String {
        switch self {
        case .shouldUseTrailingClosure:
            "GSB Macros require use trailing closure"
        case .builderAcceptsOnlyStringLiteralOrGSBMacroExpansion:
            "Builder of GSB Macros accepts only string literal or GSB Macros expansion"
        case .argumentsAcceptOnlyStringLiteral:
            "Arguments in GSB Macros accept only string literal(s)"
        case .shouldUseClosureParameterClause:
            "GSB Macros require write parameter clause (shorthand argument names: $0, $1, ... are prohibited)"
        case .invalidSyntaxOnBuilderExprAfterReplacingVariables:
            "Invalid syntax on builder expression after replacing variables"
        }
    }

    var rawValue: String {
        switch self {
        case .shouldUseTrailingClosure: "shouldUseTrailingClosure"
        case .builderAcceptsOnlyStringLiteralOrGSBMacroExpansion:
            "builderAcceptsOnlyStringLiteralOrGSBMacroExpansion"
        case .argumentsAcceptOnlyStringLiteral:
            "argumentsOnlyAcceptStringLiteral"
        case .shouldUseClosureParameterClause:
            "shouldUseClosureParameterClause"
        case .invalidSyntaxOnBuilderExprAfterReplacingVariables:
            "invalidSyntaxOnBuilderExprAfterReplacingVariables"
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "GSBMacroDiagnostic", id: rawValue)
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }

    var fixIts: [FixIt] {
        switch self {
        case .shouldUseTrailingClosure(let macroExpansion):
            guard
                let closureArgument = ClosureExprSyntax(macroExpansion.arguments.last?.expression),
                let closureArgumentIndex = macroExpansion.arguments.lastIndex(where: {
                    $0.expression.is(ClosureExprSyntax.self)
                })
            else {
                return []
            }
            var newMacroExpansion = macroExpansion
            newMacroExpansion.trailingClosure = closureArgument
            newMacroExpansion.trailingClosure?.leadingTrivia = " "
            newMacroExpansion.arguments.remove(at: closureArgumentIndex)
            newMacroExpansion.leftParen = nil
            newMacroExpansion.rightParen = nil

            return [
                FixIt(
                    message: ChangeArgumentClosureToTrailingClosure(),
                    changes: [
                        .replace(
                            oldNode: Syntax(
                                macroExpansion
                            ),
                            newNode: Syntax(
                                newMacroExpansion
                            )
                        )
                    ]
                )
            ]

        case .shouldUseClosureParameterClause(let closure, let numberOfArguments):
            let fixItVarNames = (0..<numberOfArguments).map { index in
                let isLastElement = index == numberOfArguments - 1
                return ClosureShorthandParameterSyntax(
                    name: .identifier("<#name\(index)#>"),
                    trailingComma: isLastElement ? nil : .commaToken(trailingTrivia: .space),
                    trailingTrivia: isLastElement ? .space : nil
                )
            }
            return [
                FixIt(
                    message: InsertClosureParameterClause(),
                    changes: [
                        .replace(
                            oldNode: Syntax(closure),
                            newNode: Syntax(
                                closure.with(
                                    \.signature,
                                    ClosureSignatureSyntax(
                                        leadingTrivia: .space,
                                        parameterClause: .simpleInput(
                                            ClosureShorthandParameterListSyntax(fixItVarNames)
                                        )
                                    )
                                )
                            )
                        )
                    ]
                )
            ]

        case .builderAcceptsOnlyStringLiteralOrGSBMacroExpansion,
            .argumentsAcceptOnlyStringLiteral,
            .invalidSyntaxOnBuilderExprAfterReplacingVariables:
            return []
        }
    }

    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self, fixIts: fixIts)
    }
}

private struct ChangeArgumentClosureToTrailingClosure: FixItMessage {
    var message: String {
        "change closure in arguments to trailing closure"
    }

    var fixItID: MessageID {
        MessageID(
            domain: "GSBMacroDiagnostic",
            id: "ChangeArgumentClosureToTrailingClosure"
        )
    }
}

private struct InsertClosureParameterClause: FixItMessage {
    var message: String {
        "insert closure parameter clause"
    }

    var fixItID: SwiftDiagnostics.MessageID {
        MessageID(
            domain: "GSBMacroDiagnostic",
            id: "InsertClosureParameterClause"
        )
    }
}
