import SwiftSyntax

extension ClosureExprSyntax {
    func getParameterNames() -> [String]? {
        guard let parameterClause = signature?.parameterClause else {
            return nil
        }

        return switch parameterClause {
        case .simpleInput(let closureShorthandParameterListSyntax):
            closureShorthandParameterListSyntax.map(\.name.text)
        case .parameterClause(let closureParameterClauseSyntax):
            closureParameterClauseSyntax.parameters.map(\.firstName.text)
        }
    }
}

extension ExprSyntaxProtocol {
    func getAsString() -> String? {
        StringLiteralExprSyntax(self)?.segments.description
    }

    func getAsStringArray() -> [String]? {
        guard let array = ArrayExprSyntax(self) else {
            return nil
        }

        let stringArray = array.elements.compactMap { $0.expression.getAsString() }
        return array.elements.count == stringArray.count ? stringArray : nil
    }

    func getAsTupleArray() -> [TupleExprSyntax]? {
        guard let array = ArrayExprSyntax(self) else {
            return nil
        }
        let tupleArray = array.elements.compactMap { TupleExprSyntax($0.expression) }

        return array.elements.count == tupleArray.count ? tupleArray : nil
    }
}

extension StringLiteralExprSyntax {
    static func multiline(content: String) -> Self {
        let segments: [StringLiteralSegmentListSyntax.Element] = content.split(separator: "\n").map
        {
            .init(StringSegmentSyntax(content: .stringSegment(String($0) + "\n")))
        }

        return StringLiteralExprSyntax(
            openingQuote: .multilineStringQuoteToken(),
            segments: .init(itemsBuilder: {
                segments
            }),
            closingQuote: .multilineStringQuoteToken()
        )
    }
}

extension TupleExprSyntax {
    func getElementsAsStringArray() -> [String]? {
        let stringArray = elements.compactMap { $0.expression.getAsString() }

        return elements.count == stringArray.count ? stringArray : nil
    }
}

extension [TupleExprSyntax] {
    func getElementsAsStringArray() -> [[String]]? {
        let string2DArray = compactMap { $0.getElementsAsStringArray() }

        return count == string2DArray.count ? string2DArray : nil
    }
}
