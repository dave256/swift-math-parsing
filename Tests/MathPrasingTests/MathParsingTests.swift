import XCTest
@testable import MathParsing

final class PostfixTokensTests: XCTestCase {
    func testPostfixCombinations() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.mul),
            .number(Combinations(n: 5, k: 2)),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(10),
            .binaryOperator(.mul),
        ]
        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }

    func testAdd() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.add),
            .number(3),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(3),
            .binaryOperator(.add),
        ]

        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }

    func testPrecedence() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.add),
            .number(3),
            .binaryOperator(.mul),
            .number(4),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(3),
            .number(4),
            .binaryOperator(.mul),
            .binaryOperator(.add),
        ]

        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }

    func testNegation() throws {
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

        let postfix: [Token] = [
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

        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }
}

final class evalPostfixTests: XCTestCase {
    func testAdd() throws {
        let postfix: [Token] = [
            .number(2),
            .number(3),
            .binaryOperator(.add),
        ]

        let actual = try postfix.evaluateAsPostfix()
        XCTAssertEqual(actual, 5)
    }

    func testPrecedence() throws {
        let postfix: [Token] = [
            .number(2),
            .number(3),
            .number(4),
            .binaryOperator(.mul),
            .binaryOperator(.add),
        ]

        let actual = try postfix.evaluateAsPostfix()
        XCTAssertEqual(actual, 14)
    }

    func testNegation() throws {
        let postfix: [Token] = [
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
        let actual = try postfix.evaluateAsPostfix()
        XCTAssertEqual(actual, 36)
    }
}
