import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import GSBMacros

final class GSBMacroDiagnosticsTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: GSBMacroSpec.macrosTable
        ) {
            super.invokeTest()
        }
    }

    func testShouldUseTrailingClosure() {
        assertMacro {
            #"""
            #gsbDecl(body: {
                """
                func add(a: Int, b: Int) -> Int {
                    a + b
                }
                """
            })
            """#
        } diagnostics: {
            #"""
            #gsbDecl(body: {
                     ┬───
                     ╰─ 🛑 GSB Macros require use trailing closure
                        ✏️ change closure in arguments to trailing closure
                """
                func add(a: Int, b: Int) -> Int {
                    a + b
                }
                """
            })
            """#
        } fixes: {
            #"""
            #gsbDecl {
                """
                func add(a: Int, b: Int) -> Int {
                    a + b
                }
                """
            }
            """#
        } expansion: {
            """
            func add(a: Int, b: Int) -> Int {
                    a + b
                }
            """
        }

        assertMacro {
            #"""
            #gsbExpr(body: closure)
            """#
        } diagnostics: {
            """
            #gsbExpr(body: closure)
                     ┬───
                     ╰─ 🛑 GSB Macros require use trailing closure
            """
        }

        assertMacro {
            #"""
            #gsbDecl {
                #gsbForEach(["Int", "UInt"], body: { int in
                    """
                    func add(a: \(int), b: \(int)) -> \(int) {
                        a + b
                    }
                    """
                })
            }
            """#
        } diagnostics: {
            #"""
            #gsbDecl {
                #gsbForEach(["Int", "UInt"], body: { int in
                                             ┬───
                                             ╰─ 🛑 GSB Macros require use trailing closure
                                                ✏️ change closure in arguments to trailing closure
                    """
                    func add(a: \(int), b: \(int)) -> \(int) {
                        a + b
                    }
                    """
                })
            }
            """#
        } fixes: {
            #"""
            #gsbDecl {
                #gsbForEach["Int", "UInt"],  { int in
                    """
                    func add(a: \(int), b: \(int)) -> \(int) {
                        a + b
                    }
                    """
                }
            }
            """#
        }
    }

    func testOnlyAcceptStringLiteralOrGSBMacroExpansion() {
        assertMacro {
            #"""
            #gsbExpr {
                10
            }
            """#
        } diagnostics: {
            """
            #gsbExpr {
                10
                ┬─
                ╰─ 🛑 Builder of GSB Macros accepts only string literal or GSB Macros expansion
            }
            """
        }

        assertMacro {
            #"""
            #gsbExpr {
                let number = 10
            }
            """#
        } diagnostics: {
            """
            #gsbExpr {
                let number = 10
                ┬──────────────
                ╰─ 🛑 Builder of GSB Macros accepts only string literal or GSB Macros expansion
            }
            """
        }

        assertMacro {
            #"""
            #gsbExpr {
                stringValue
            }
            """#
        } diagnostics: {
            """
            #gsbExpr {
                stringValue
                ┬──────────
                ╰─ 🛑 Builder of GSB Macros accepts only string literal or GSB Macros expansion
            }
            """
        }

        assertMacro {
            #"""
            #gsbExpr {
                #stringfy(10)
            }
            """#
        } diagnostics: {
            """
            #gsbExpr {
                #stringfy(10)
                ┬────────────
                ╰─ 🛑 Builder of GSB Macros accepts only string literal or GSB Macros expansion
            }
            """
        }
    }

    func testArgumentsOnlyAcceptStringLiteral() {
        assertMacro {
            #"""
            #gsbLet(a) { varName in
                """
                let \(varName) = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbLet(a) { varName in
                    ┬
                    ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let \(varName) = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbIf(a, equalsTo: b) {
                """
                let number = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbIf(a, equalsTo: b) {
                   ┬
                   ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let number = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbIf("Int", equalsTo: b) {
                """
                let number = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbIf("Int", equalsTo: b) {
                                    ┬
                                    ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let number = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbIf("Int", in: b) {
                """
                let number = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbIf("Int", in: b) {
                              ┬
                              ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let number = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbIf("Int", in: ["Int", c, d]) {
                """
                let number = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbIf("Int", in: ["Int", c, d]) {
                              ┬────────────
                              ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let number = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbForEach(a) { varName in
                """
                let \(varName) = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbForEach(a) { varName in
                        ┬
                        ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let \(varName) = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbForEach(["a", b]) { varName in
                """
                let \(varName) = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbForEach(["a", b]) { varName in
                        ┬───────
                        ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let \(varName) = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbForEach([("a1", "a2"), (b1, b2)]) { varName in
                """
                let \(varName) = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbForEach([("a1", "a2"), (b1, b2)]) { varName in
                        ┬───────────────────────
                        ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let \(varName) = 10
                """
            }
            """#
        }

        assertMacro {
            #"""
            #gsbForEach([("a1", "a2"), b]) { varName in
                """
                let \(varName) = 10
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbForEach([("a1", "a2"), b]) { varName in
                        ┬────────────────
                        ╰─ 🛑 Arguments in GSB Macros accept only string literal(s)
                """
                let \(varName) = 10
                """
            }
            """#
        }
    }

    func testShouldUseClosureParameterClause() {
        assertMacro {
            #"""
            #gsbLet("one") {
                """
                let \($0) = 1
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbLet("one") {
                           ╰─ 🛑 GSB Macros require write parameter clause (shorthand argument names: $0, $1, ... are prohibited)
                              ✏️ insert closure parameter clause
                """
                let \($0) = 1
                """
            }
            """#
        } fixes: {
            #"""
            #gsbLet("one") { <#name0#> in
                """
                let \($0) = 1
                """
            }
            """#
        } expansion: {
            #"""
            """
                let \($0) = 1
                """
            """#
        }

        assertMacro {
            #"""
            #gsbForEach([("one", "two")]) {
                """
                let \($0) = 1
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbForEach([("one", "two")]) {
                                          ╰─ 🛑 GSB Macros require write parameter clause (shorthand argument names: $0, $1, ... are prohibited)
                                             ✏️ insert closure parameter clause
                """
                let \($0) = 1
                """
            }
            """#
        } fixes: {
            #"""
            #gsbForEach([("one", "two")]) { <#name0#>, <#name1#> in
                """
                let \($0) = 1
                """
            }
            """#
        } expansion: {
            #"""
            """
                let \($0) = 1
                """
            """#
        }
    }

    func testInvalidSyntaxOnBuilderExprAfterReplacingVariables() {
        assertMacro {
            #"""
            #gsbLet(#""""}()"#) { symbol in
                """
                \(symbol)
                """
            }
            """#
        } diagnostics: {
            #"""
            #gsbLet(#""""}()"#) { symbol in
            ╰─ 🛑 Invalid syntax on builder expression after replacing variables
                """
                \(symbol)
                """
            }
            """#
        }
    }
}
