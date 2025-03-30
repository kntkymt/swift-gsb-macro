import GSB
import Foundation

struct StorageTest {
    struct Storage {
        var bool: Bool = false
        var string: String = ""
        var int: Int = 0
    }
    func assert<T: Equatable>(_ a: T, _ b: T) {
        print(a == b)
    }

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
