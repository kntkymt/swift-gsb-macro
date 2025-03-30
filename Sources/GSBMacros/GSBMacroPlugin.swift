import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct GSBMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = GSBMacroSpec.allCases.map(\.macroType)
}
