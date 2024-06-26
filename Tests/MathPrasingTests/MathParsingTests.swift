import XCTest
@testable import MathParsing

final class InfixToPostfixTests: XCTestCase {
    func testPostfixCombinations() throws {
        let infixTokens: [Token] = [
            .number(2),
            .binaryOperator(.mul),
            .numberConvertible(try Combinations(n: 5, k: 2)),
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
        let e = try XCTUnwrap(Equation(infixString: "23+ 45"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 68)
    }

    func testNegationString() throws {
        let e = try XCTUnwrap(Equation(infixString: "60/-(2 + -(1 + 1) * 2) + 3 * 2"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 36)
    }

    func testFactorial() throws {
        let e = try XCTUnwrap(Equation(infixString: "5!"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 120)
    }

    func testFactorialExpr1() throws {
        let e = try XCTUnwrap(Equation(infixString: "5 * 4!"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 120)
    }

    func testFactorialExpr2() throws {
        let e = try XCTUnwrap(Equation(infixString: "5 + 4!"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 29)
    }

    func testFactorialExprParen() throws {
        let e = try XCTUnwrap(Equation(infixString: "(2 + 3)!"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 120)
    }

    func testFactorialFactorial() throws {
        let e = try XCTUnwrap(Equation(infixString: "3!!"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 720)
    }

    func testFactorialFactorialParen() throws {
        let e = try XCTUnwrap(Equation(infixString: "(3!)!"))
        let actual = try e.evaluate()
        XCTAssertEqual(actual, 720)
    }

}

final class IntegerPartitionTests: XCTestCase {
    func testAnyAnyOnto() throws {
        let n = 7
        let k = 10
        let expected: Int64 = 3

        let actual = try IntegerPartition(n: n, k: k).eval
        XCTAssertEqual(actual, expected)
    }
}

final class CombinatoricFunctionTests: XCTestCase {
    func testOnto() throws {
        let actual = try OntoFunctions(n: 3, k: 7).eval
        XCTAssertEqual(actual, 1806)

    }

    func testStirling() throws {
        let actual = try Stirling2(n: 3, k: 7).eval
        XCTAssertEqual(actual, 301)
    }
}

final class SummationTest: XCTestCase {

    func testIdentity() throws {
        let equation = Equation(tokens: [.variable("k")])
        let s = try XCTUnwrap(Summation(start: 1, end: 10, equation: equation))
        XCTAssertEqual(s.eval, 55)
    }

    func testKSquared() throws {
        let equation = try XCTUnwrap(Equation(infixString: "k^2"))
        let s = try XCTUnwrap(Summation(start: 1, end: 10, equation: equation))
        XCTAssertEqual(s.eval, 385)
    }
}
