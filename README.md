# GSBMacro - Generate Swift Boilerplate Macro

GSB Macro helps you generate boilerplate declarations and expressions in Swift. This macro is heavily inspired by [gyb](https://github.com/swiftlang/swift/blob/main/utils/gyb.py).

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/kntkymt/swift-gsb-macro", from: "0.0.1")
```

## Quick Overview

- Generate arbitrary declarations using `#gsbDecl`
- Generate repeated code using `#gsbForEach`

```swift
import GSB

struct Storage {
    var bool: Bool = false
    var string: String = ""
    var int: Int = 0
}
func assert<T: Equatable>(_ a: T, _ b: T) {
    print(a == b)
}

struct StorageTest {
    #gsbDecl {
        #gsbForEach(
            [
                ("bool", "false", "true"),
                (
                    "string",
                    #""""#,
                    #""value""#
                ),
                ("int", "0", "10"),
            ]
        ) { key, defaultValue, newValue in
            """
            func testStorageReadWrite\(key)() {
                var storage = Storage()

                assert(storage.\(key), \(defaultValue))
                storage.\(key) = \(newValue)
                assert(storage.\(key), \(newValue))
            }
            """
        }
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
struct StorageTest {
    func testStorageReadWritebool() {
        var storage = Storage()
        
        assert(storage.bool, false)
        storage.bool = true
        assert(storage.bool, true)
    }
    
    func testStorageReadWritestring() {
        var storage = Storage()
        
        assert(storage.string, "")
        storage.string = "value"
        assert(storage.string, "value")
    }
    
    func testStorageReadWriteint() {
        var storage = Storage()
        
        assert(storage.int, 0)
        storage.int = 10
        assert(storage.int, 10)
    }
}
```

</details>

- You can also generate arbitrary expressions using `#gsbExpr`.

```swift
import GSB

struct StorageTest {
    func testStorageReadWrite() {
        #gsbExpr {
            """
            var storage = Storage()
            """

            #gsbForEach(
                [
                    ("bool", "false", "true"),
                    (
                        "string",
                        #""""#,
                        #""value""#
                    ),
                    ("int", "0", "10"),
                ]
            ) { key, defaultValue, newValue in
                """
                assert(storage.\(key), \(defaultValue))
                storage.\(key) = \(newValue)
                assert(storage.\(key), \(newValue))
                """
            }
        }
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
struct StorageTest {
    func testStorageReadWrite() {
        {
            var storage = Storage()
            
            assert(storage.bool, false)
            storage.bool = true
            assert(storage.bool, true)
            
            assert(storage.string, "")
            storage.string = "value"
            assert(storage.string, "value")
            
            assert(storage.int, 0)
            storage.int = 10
            assert(storage.int, 10)
        }()
    }
}
```
</details>

## Guides
### GSB Builder Syntax

All GSB macros accept closure `@GSBBuilder () -> [String]`. 
GSBBuilder accepts only following 2 type of elements.

- StringLiteral (not variable of String)
- GSB macros expansion

```swift
let bye = "func bye() {}"
#gsbDecl {
    // OK: String Literal
    "func hello() {}"
    
    // Error: String variable
    bye
    
    // OK: GSB macros expansion
    #gsbForEach(...) { ... }
    
    // Error: Other macros expansion
    #stringfy(...)
}
```

Some GSBBuilder of GSB macros, like `#gsbForEach`, accept parameters.

You can use these parameters within the macro body using Swift-style string interpolation `\\(...)`.
The GSB macro system will then replace the interpolated expressions with the actual arguments during macro expansion.

```swift
#gsbForEach(["a", "b", "c"]) { keyword in // you can declar arbitary parameter name here
    """
    func \(keyword)() {
    }
    """
}

// expanded to
func a() {}
func b() {}
func c() {}
```

### TopLevel Macros

There are two top-level macros for declarations and expressions. Basically, you will write one of these, then write control flow macros inside its closure.

#### #gsbDecl

A freestanding declaration macro.

Generates any kinds of declarations. you can generate various declarations such as declar types (struct/enum/class/actor/protocol), However, you cannot declar it in global scope due to [the restriction of macro which generate arbitrary names](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0389-attached-macros.md#restrictions-on-arbitrary-names).

```swift
extension Requests {
    #gsbDecl {
        """
        struct GetMyList: Request {
            var path: String {
                "/myList"
            }
            
            var method: HTTPMethod {
                .get
            }
        }
        """
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
extension Requests {
    struct GetMyList: Request {
        var path: String {
            "/myList"
        }
        
        var method: HTTPMethod {
            .get
        }
    }
}
```

</details>

#### #gsbExpr

A freestanding expression macro that generates expression executing builder content.

```swift
func printNumber() {
    #gsbExpr {
        """
        let number = 10
        print(number)
        """
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
func printNumber() {
    {
        let number = 10
        print(number)
    }()
}
```

</details>

### ControlFlow Macros

ControlFlow Macros are freestanding expression macros that generate string literal based on builder content and specific control flow of each macros.

#### #gsbForEach

A freestanding expression macro that expand builder content based collection of string on arguments.

```swift
import SwiftUI

extension Image {
    #gsbDecl {
        #gsbForEach(
            [
                ("clear", "xmark.circle.fill"),
                ("search", "magnifyingglass"),
                ("down", "chevron.down"),
                ("filter", "line.3.horizontal.decrease.circle")
            ]
        ) { varName, sysName in
            """
            static var \(varName): Image {
                Image(systemName: "\(sysName)")
            }
            """
        }
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
extension Image {
    static var clear: Image {
        Image(systemName: "xmark.circle.fill")
    }
    
    static var search: Image {
        Image(systemName: "magnifyingglass")
    }
    
    static var down: Image {
        Image(systemName: "chevron.down")
    }
    
    static var filter: Image {
        Image(systemName: "line.3.horizontal.decrease.circle")
    }
}
```

</details>

#### #gsbIf

A freestanding expression macro that expand builder content if fullfill the condition on argument.

```swift
func assert<T: Equatable>(_ a: T, _ b: T) {
    print(a == b)
}

struct FloatTest {
    #gsbDecl {
        #gsbForEach(
            [
                "Float",
                "Double",
                "Float16"
            ]
        ) { floatType in
            #gsbIf("\(floatType)", equalsTo: "Float16") {
                "@available(macOS 11.0, *)"
            }
            """
            func testFloatMultiply\(floatType)() {
                let float: \(floatType) = 10
                assert(float * float, 100)
            }
            """
        }
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
struct FloatTest {
    func testFloatMultiplyFloat() {
        let float: Float = 10
        assert(float * float, 100)
    }
    
    func testFloatMultiplyDouble() {
        let float: Double = 10
        assert(float * float, 100)
    }
    
    @available(macOS 11.0, *)
    func testFloatMultiplyFloat16() {
        let float: Float16 = 10
        assert(float * float, 100)
    }
}
```

</details>

#### #gsbLet

A freestanding expression macro that declar new variable with other string literal.

```swift
enum Matrix {
    #gsbDecl {
        #gsbForEach(["2", "3"]) { rows in
            #gsbForEach(["2", "3"]) { columns in
                #gsbLet("Matrix\(rows)x\(columns)") { matrix in
                    """
                    struct \(matrix) {
                        var rows: Int {
                            \(rows)
                        }
                    
                        var columns: Int {
                            \(columns)
                        }
                    }
                    """
                }
            }
        }
    }
}
```

<details>
<summary>macro expansion result</summary>

```swift
enum Matrix {
    struct Matrix2x2 {
        var rows: Int {
            2
        }
        
        var columns: Int {
            2
        }
    }
    
    struct Matrix2x3 {
        var rows: Int {
            2
        }
        
        var columns: Int {
            3
        }
    }
    
    struct Matrix3x2 {
        var rows: Int {
            3
        }
        
        var columns: Int {
            2
        }
    }
    
    struct Matrix3x3 {
        var rows: Int {
            3
        }
        
        var columns: Int {
            3
        }
    }
}
```

</details>