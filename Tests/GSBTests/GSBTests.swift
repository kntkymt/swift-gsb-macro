import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import GSBMacros

final class GSBTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: GSBMacroSpec.macrosTable
        ) {
            super.invokeTest()
        }
    }

    func testGSBDecl() {
        assertMacro {
            #"""
            #gsbDecl {
                """
                func add(a: Int, b: Int) -> Int {
                    a + b
                }
                """

                """
                func sub(a: Int, b: Int) -> Int {
                    a - b
                }
                """
            }
            """#
        } expansion: {
            """
            func add(a: Int, b: Int) -> Int {
                    a + b
                }

                func sub(a: Int, b: Int) -> Int {
                    a - b
                }
            """
        }
    }

    func testGSBExpr() {
        assertMacro {
            #"""
            #gsbExpr {
                """
                func assert(_ a: Int, b: Int) {
                    a == b
                }
                let a = 10
                assert(a, 10)
                """

                """
                let b = -50
                assert(b, 10)
                """
            }
            """#
        } expansion: {
            """
            {
                func assert(_ a: Int, b: Int) {
                        a == b
                    }
                    let a = 10
                    assert(a, 10)

                    let b = -50
                    assert(b, 10)
            }()
            """
        }
    }

    func testGSBFor() {
        assertMacro {
            #"""
            #gsbForEach(["Int", "Int64"]) { int in
                """
                func zero() -> \(int) {
                    0
                }
                """

                """
                func one() -> \(int) {
                    1
                }
                """
            }
            """#
        } expansion: {
            #"""
            """
                func zero() -> Int {
                    0
                }
                func one() -> Int {
                    1
                }
                func zero() -> Int64 {
                    0
                }
                func one() -> Int64 {
                    1
                }
                """
            """#
        }
    }

    func testGSBIFIn() {
        assertMacro {
            #"""
            #gsbIf("Int", in: ["Int", "Int64"]) {
                """
                func zero() -> Int {
                    0
                }
                """

                """
                func one() -> Int {
                    1
                }
                """
            }
            """#
        } expansion: {
            #"""
            """
                func zero() -> Int {
                    0
                }
                func one() -> Int {
                    1
                }
                """
            """#
        }

        assertMacro {
            #"""
            #gsbIf("UInt", in: ["Int", "Int64"]) {
                """
                func zero() -> Int {
                    0
                }
                """

                """
                func one() -> Int {
                    1
                }
                """
            }
            """#
        } expansion: {
            #"""
            """
            """
            """#
        }
    }

    func testGSBIFNotIn() {
        assertMacro {
            #"""
            #gsbIf("Int", notIn: ["Int", "Int64"]) {
                """
                func zero() -> Int {
                    0
                }
                """

                """
                func one() -> Int {
                    1
                }
                """
            }
            """#
        } expansion: {
            #"""
            """
            """
            """#
        }

        assertMacro {
            #"""
            #gsbIf("UInt", notIn: ["Int", "Int64"]) {
                """
                func zero() -> Int {
                    0
                }
                """

                """
                func one() -> Int {
                    1
                }
                """
            }
            """#
        } expansion: {
            #"""
            """
                func zero() -> Int {
                    0
                }
                func one() -> Int {
                    1
                }
                """
            """#
        }
    }

    func testGSBLet() {
        assertMacro {
            #"""
            #gsbLet("Int") { int in
                """
                func zero() -> \(int) {
                    0
                }
                """

                """
                func one() -> \(int) {
                    1
                }
                """
            }
            """#
        } expansion: {
            #"""
            """
                func zero() -> Int {
                    0
                }
                func one() -> Int {
                    1
                }
                """
            """#
        }
    }

    func testForIfLetCombined() {
        assertMacro {
            #"""
            #gsbDecl {
                #gsbForEach(["Int", "Int64", "UInt", "UInt64"]) { int in
                    """
                    func zero() -> \(int) {
                        0
                    }
                    
                    func one() -> \(int) {
                        1
                    }
                    """

                    #gsbIf("\(int)", notIn: ["UInt", "UInt64"]) {
                        """
                        func minusOne() -> \(int) {
                            -1
                        }
                        """
                    }
                }
            }
            """#
        } expansion: {
            """
            func zero() -> Int {
                        0
                    }
                    
                    func one() -> Int {
                        1
                    }

                        func minusOne() -> Int {
                            -1
                        }

                    func zero() -> Int64 {
                        0
                    }
                    
                    func one() -> Int64 {
                        1
                    }

                        func minusOne() -> Int64 {
                            -1
                        }

                    func zero() -> UInt {
                        0
                    }
                    
                    func one() -> UInt {
                        1
                    }

                    func zero() -> UInt64 {
                        0
                    }
                    
                    func one() -> UInt64 {
                        1
                    }
            """
        }

        assertMacro {
            #"""
            #gsbExpr {
                #gsbForEach(["Int", "Int64", "UInt", "UInt64"]) { int in
                    #gsbForEach(["1", "2"]) { value in
                        #gsbLet("a_\(int)_\(value)") { varName in
                            """
                            let \(varName): \(int) = \(value)
                            assert(a: \(varName), b: \(value))
                            """
                        }
                    }
                }
            }
            """#
        } expansion: {
            """
            {
                let a_Int_1: Int = 1
                                assert(a: a_Int_1, b: 1)

                                let a_Int_2: Int = 2
                                assert(a: a_Int_2, b: 2)

                                let a_Int64_1: Int64 = 1
                                assert(a: a_Int64_1, b: 1)

                                let a_Int64_2: Int64 = 2
                                assert(a: a_Int64_2, b: 2)

                                let a_UInt_1: UInt = 1
                                assert(a: a_UInt_1, b: 1)

                                let a_UInt_2: UInt = 2
                                assert(a: a_UInt_2, b: 2)

                                let a_UInt64_1: UInt64 = 1
                                assert(a: a_UInt64_1, b: 1)

                                let a_UInt64_2: UInt64 = 2
                                assert(a: a_UInt64_2, b: 2)
            }()
            """
        }
    }
}
