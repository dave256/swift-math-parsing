import XCTest
@testable import MathParsing

final class PostfixTokensTests: XCTestCase {
    func testAdd() {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.add),
            .number(3),
        ]

        let expected: [Token] = [
            .number(2),
            .number(3),
            .binaryOperator(.add),
        ]

        let e = MathExpression(infixTokens: infixTokens)
        let actual = e.postfixTokens()

        XCTAssertEqual(actual, expected)
    }

    func testPrecedence() {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.add),
            .number(3),
            .binaryOperator(.mul),
            .number(4),
        ]

        let expected: [Token] = [
            .number(2),
            .number(3),
            .number(4),
            .binaryOperator(.mul),
            .binaryOperator(.add),
        ]

        let e = MathExpression(infixTokens: infixTokens)
        let actual = e.postfixTokens()
        XCTAssertEqual(actual, expected)
    }

    func testNegation() {
        let infixTokens: [Token] = [
            .number(60),
            .binaryOperator(.div),
            .unaryOperator(.neg),
            .leftParen,
            .number(2),
            .binaryOperator(.add),
            .unaryOperator(.neg),
            .leftParen,
            .number(1),
            .binaryOperator(.add),
            .number(1),
            .rightParen,
            .binaryOperator(.mul),
            .number(2),
            .rightParen,
            .binaryOperator(.add),
            .number(3),
            .binaryOperator(.mul),
            .number(2),
        ]

        let expected: [Token] = [
            .number(60),
            .number(2),
            .number(1),
            .number(1),
            .binaryOperator(.add),
            .unaryOperator(.neg),
            .binaryOperator(.mul),
            .number(2),
            .binaryOperator(.add),
            .unaryOperator(.neg),
            .binaryOperator(.div),
            .number(3),
            .number(2),
            .binaryOperator(.mul),
            .binaryOperator(.add),
        ]

        let e = MathExpression(infixTokens: infixTokens)
        let actual = e.postfixTokens()
        XCTAssertEqual(actual, expected)
    }
}
