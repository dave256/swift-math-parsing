import XCTest
@testable import MathParsing

final class InfixToPostfixTests: XCTestCase {
    func testPostfixCombinations() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.mul),
            .numberConvertible(Combinations(n: 5, k: 2)),
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

    func testPrecedence1() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.add),
            .number(3),
            .binaryOperator(.mul),
            .number(5),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(3),
            .number(5),
            .binaryOperator(.mul),
            .binaryOperator(.add),
        ]

        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }

    func testPrecedence2() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.mul),
            .number(3),
            .binaryOperator(.add),
            .number(5),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(3),
            .binaryOperator(.mul),
            .number(5),
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

    func testExponentiation() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.pow),
            .number(3),
            .binaryOperator(.pow),
            .number(4),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(3),
            .number(4),
            .binaryOperator(.exp),
            .binaryOperator(.exp)
        ]

        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }

    func testExponentiationParenthesis() throws {
        let infixTokens: [Token] = [
            .leftParen,
            .number(2),
            .binaryOperator(.pow),
            .number(3),
            .rightParen,
            .binaryOperator(.pow),
            .number(4),
        ]

        let postfix: [Token] = [
            .number(2),
            .number(3),
            .binaryOperator(.exp),
            .number(4),
            .binaryOperator(.exp)
        ]

        let actual = try infixTokens.infixToPostfix()
        XCTAssertEqual(actual, postfix)
    }
}

final class EvalPostfixTests: XCTestCase {
    func testAdd() throws {
        let postfix: [Token] = [
            .number(2),
            .number(3),
            .binaryOperator(.add),
        ]

        let actual = try postfix.evaluateAsPostfix()
        XCTAssertEqual(actual, 5)
    }

    func testPrecedence1() throws {
        let postfix: [Token] = [
            .number(2),
            .number(3),
            .number(5),
            .binaryOperator(.mul),
            .binaryOperator(.add),
        ]

        let actual = try postfix.evaluateAsPostfix()
        XCTAssertEqual(actual, 17)
    }

    func testPrecedence2() throws {
        let postfix: [Token] = [
            .number(2),
            .number(3),
            .number(5),
            .binaryOperator(.add),
            .binaryOperator(.mul),
        ]

        let actual = try postfix.evaluateAsPostfix()
        XCTAssertEqual(actual, 16)
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

final class EquationTest: XCTestCase {

    func testAdd() throws {
        var e = Equation()
        e.addDigit(2)
        e.addDigit(3)
        e.addOperator(.add)
        e.addNumber(45)
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 68)
    }

    func testAddString() throws {
        if let e = Equation(infixString: "23+ 45") {
            let actual = try e.evaluate()
            XCTAssertEqual(actual, 68)
        } else { XCTFail() }
    }

    func testNegationString() throws {
        if let e = Equation(infixString: "60/-(2 + -(1 + 1) * 2) + 3 * 2") {
            let actual = try e.evaluate()
            XCTAssertEqual(actual, 36)
        } else { XCTFail() }
    }

}
