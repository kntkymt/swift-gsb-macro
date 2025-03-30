import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public protocol GSBControlFlowExpressionMacro: ExpressionMacro {
    static func stringExpansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax
    ) throws -> String
}

enum GSBBuilderElement {
    case stringLiteral(String)
    case gsbMacroExpansion(GSBControlFlowMacroExpansionExpr)
}

struct GSBControlFlowMacroExpansionExpr {
    private let macroType: GSBControlFlowExpressionMacro.Type
    private let macroExpansion: MacroExpansionExprSyntax

    init?(macroExpansion: MacroExpansionExprSyntax) {
        guard let macro = GSBMacroSpec.ControlFlow(rawValue: macroExpansion.macroName.text) else {
            return nil
        }

        self.macroType = macro.macroType
        self.macroExpansion = macroExpansion
    }

    func expand() throws -> String {
        try macroType.stringExpansion(of: macroExpansion)
    }
}

private func requireGSBBuilderElements(
    of closure: ClosureExprSyntax
) throws -> [GSBBuilderElement] {
    try closure.statements.map { element in
        if let stringLiteral = StringLiteralExprSyntax(element.item) {
            GSBBuilderElement.stringLiteral(stringLiteral.segments.description)
        }
        else if let macroExpansion = MacroExpansionExprSyntax(element.item),
            let gsbMacroExpansion = GSBControlFlowMacroExpansionExpr(macroExpansion: macroExpansion)
        {
            GSBBuilderElement.gsbMacroExpansion(gsbMacroExpansion)
        }
        else {
            throw DiagnosticsError(diagnostics: [
                GSBMacroDiagnostic
                    .builderAcceptsOnlyStringLiteralOrGSBMacroExpansion
                    .diagnose(at: element)
            ])
        }
    }
}

func requireTrailingClosure(of macroExpansion: FreestandingMacroExpansionSyntax) throws
    -> ClosureExprSyntax
{
    guard let closure = macroExpansion.trailingClosure else {
        let errorNode: any SyntaxProtocol = macroExpansion.arguments.last?.label ?? macroExpansion

        throw DiagnosticsError(
            diagnostics: [
                GSBMacroDiagnostic
                    .shouldUseTrailingClosure(macroExpansion)
                    .diagnose(at: errorNode)
            ]
        )
    }

    return closure
}

func expandGSBBuilderElements(
    of macroExpansion: FreestandingMacroExpansionSyntax
) throws -> String {
    let closure = try requireTrailingClosure(of: macroExpansion)
    return try expandGSBBuilderElements(of: closure)
}

func expandGSBBuilderElements(
    of closure: ClosureExprSyntax
) throws -> String {
    let gsbElements = try requireGSBBuilderElements(of: closure)

    let content = try gsbElements.map { gsbElement in
        switch gsbElement {
        case .stringLiteral(let stringContent): stringContent
        case .gsbMacroExpansion(let gsbMacroExpansion): try gsbMacroExpansion.expand()
        }
    }
    .filter { !$0.isEmpty }
    .joined(separator: "\n")

    return content
}
