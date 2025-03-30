@resultBuilder
public struct GSBBuilder {
    public static func buildExpression(_ expression: String) -> [String] {
        [expression]
    }
    public static func buildBlock(_ components: [String]...) -> [String] {
        components.flatMap(\.self)
    }
}

// MARK: - TopLevel

@freestanding(declaration, names: arbitrary)
public macro gsbDecl(
    @GSBBuilder body: () -> [String]
) = #externalMacro(module: "GSBMacros", type: "GSBDecl")

@freestanding(expression)
public macro gsbExpr(
    @GSBBuilder body: () -> [String]
) = #externalMacro(module: "GSBMacros", type: "GSBExpr")

// MARK: - Let

@freestanding(expression)
public macro gsbLet(
    _ value: String,
    @GSBBuilder body: (String) -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBLet")

// MARK: - If

@freestanding(expression)
public macro gsbIf(
    _ variable: String,
    equalsTo value: String,
    @GSBBuilder body: () -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBIf")

@freestanding(expression)
public macro gsbIf(
    _ variable: String,
    in values: [String],
    @GSBBuilder body: () -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBIf")

@freestanding(expression)
public macro gsbIf(
    _ variable: String,
    notIn values: [String],
    @GSBBuilder body: () -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBIf")

@freestanding(expression)
public macro gsbIf(
    _ variable: String,
    notEqualsTo value: String,
    @GSBBuilder body: () -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBIf")

// MARK: - For

@freestanding(expression)
public macro gsbForEach(
    _ arguments: [String],
    @GSBBuilder body: (String) -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBForEach")

@freestanding(expression)
public macro gsbForEach(
    _ arguments: [(String, String)],
    @GSBBuilder body: (String, String) -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBForEach")

@freestanding(expression)
public macro gsbForEach(
    _ arguments: [(String, String, String)],
    @GSBBuilder body: (String, String, String) -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBForEach")

@freestanding(expression)
public macro gsbForEach(
    _ arguments: [(String, String, String, String)],
    @GSBBuilder body: (String, String, String, String) -> [String]
) -> String = #externalMacro(module: "GSBMacros", type: "GSBForEach")
