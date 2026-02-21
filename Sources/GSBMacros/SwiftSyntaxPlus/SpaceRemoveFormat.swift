import SwiftSyntax
import SwiftBasicFormat

internal extension SyntaxProtocol {
    func reviseIndent(initialIndentation: Trivia = []) -> Self {
        // .formatted (BasicFormat) won't decrise indent
        SpaceRemoveFormat()
            .rewrite(self)
            .formatted(using: BasicFormat(initialIndentation: initialIndentation))
            .cast(Self.self)
    }
}

final class SpaceRemoveFormat: SyntaxRewriter {
    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        let trimmed =
            token
            .with(\.leadingTrivia, .init(pieces: token.leadingTrivia.filter { !$0.isSpaceOrTab }))
            .with(\.trailingTrivia, .init(pieces: token.trailingTrivia.filter { !$0.isSpaceOrTab }))

        return super.visit(
            trimmed
        )
    }
}
