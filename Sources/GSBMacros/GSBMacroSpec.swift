import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum GSBMacroSpec: CaseIterable {
    public enum TopLevel: String, CaseIterable {
        case gsbDecl
        case gsbExpr

        public var macroType: Macro.Type {
            switch self {
            case .gsbDecl: GSBDecl.self
            case .gsbExpr: GSBExpr.self
            }
        }
    }
    public enum ControlFlow: String, CaseIterable {
        case gsbForEach
        case gsbLet
        case gsbIf

        public var macroType: GSBControlFlowExpressionMacro.Type {
            switch self {
            case .gsbForEach: GSBForEach.self
            case .gsbLet: GSBLet.self
            case .gsbIf: GSBIf.self
            }
        }
    }
    case topLevel(TopLevel)
    case controlFlow(ControlFlow)

    public static var allCases: [GSBMacroSpec] {
        TopLevel.allCases.map { .topLevel($0) }
            + ControlFlow.allCases.map { .controlFlow($0) }
    }

    public var macroName: String {
        switch self {
        case .topLevel(let gSBTopLevelMacro): gSBTopLevelMacro.rawValue
        case .controlFlow(let gSBControlFlowMacro): gSBControlFlowMacro.rawValue
        }
    }

    public var macroType: Macro.Type {
        switch self {
        case .topLevel(let topLevel): topLevel.macroType
        case .controlFlow(let controlFlow): controlFlow.macroType
        }
    }
}

extension GSBMacroSpec {
    public static var macrosTable: [String: Macro.Type] {
        Dictionary(uniqueKeysWithValues: allCases.map { ($0.macroName, $0.macroType) })
    }
}
