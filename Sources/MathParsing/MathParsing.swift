
func power(_ base: Int64, _ exp: Int64) -> Int64 {
    var result: Int64 = 1
    if exp > 0 {
        for _ in 0..<exp {
            result *= base
        }
    }
    return result
}

public protocol Int64Convertible {
    var eval: Int64 { get }
}

public protocol Precedence {
    var precedence: Int { get }
}

extension Int: Int64Convertible {
    public var eval: Int64 { Int64(self) }
}

extension Int64: Int64Convertible {
    public var eval: Int64 { self }
}

// MARK: BinaryOperator
public enum BinaryOperator: Equatable {
    case add
    case sub
    case mul
    case div
    case mod
    // use pow when constructing infix expressions
    case pow
    // extra operator for right to left parenthesis for exponentiation
    case exp
}

extension BinaryOperator {
    var isPow: Bool {
        switch self {
            case .pow:
                return true
            default:
                return false
        }
    }
}

extension BinaryOperator: Precedence {
    public var precedence: Int {
        switch self {
            case .add, .sub:
                return 1
            case .mul, .div, .mod:
                return 2
            case .exp:
                return 4
            case .pow:
                return 5
        }
    }

    func evaluate(lhs: Int64, rhs: Int64) -> Int64 {
        switch self {
            case .add:
                return lhs + rhs
            case .sub:
                return lhs - rhs
            case .mul:
                return lhs * rhs
            case .div:
                return lhs / rhs
            case .mod:
                return lhs % rhs
            case .pow, .exp:
                return power(lhs, rhs)
        }
    }
}

extension BinaryOperator: CustomStringConvertible {
    public var description: String {
        switch self {
            case .add:
                return "+"
            case .sub:
                return "-"
            case .mul:
                return "*"
            case .div:
                return "/"
            case .mod:
                return "%"
            case .pow, .exp:
                return "^"
        }
    }
}

// MARK: UnaryOperator
public enum UnaryOperator: Equatable {
    case plus
    case neg

    func evaluate(value: Int64) -> Int64 {
        switch self {
            case .plus:
                return value
            case .neg:
                return -value
        }
    }
}

extension UnaryOperator: Precedence {
    public var precedence: Int { return 3 }
}

extension UnaryOperator: CustomStringConvertible {
    public var description: String {
        switch self {
            case .plus:
                return "+"
            case .neg:
                return "-"
        }
    }
}

// MARK: Parsing Errors
enum InfixToPostfixError: Error {
    // array of Tokens and the index or thr right parenthesis with no matching left parenthesis
    case noMatchingLeftParen([Token], Int)
}

enum PostfixError: Error {
    // parenthesis (left or right), array of Tokens, and index of the parenthesis
    case containsParenthesis(String, [Token], Int)
    // operand, array of Tokens, and index of the operand
    case binaryOperatorMissingOperands(String, [Token], Int)
    // operand, array of Tokens, and index of the operand
    case unaryOperatorMissingOperand(String, [Token], Int)
    /// number of items on stack, Tokens,
    case notOneValueOnStack(Int, [Token])
    /// missing value for variable
    case missingVariableValue(String)
}

// MARK: Token
public enum Token {
    case leftParen
    case rightParen
    case binaryOperator(BinaryOperator)
    case unaryOperator(UnaryOperator)
    case number(Int64)
    case numberConvertible(Int64Convertible)
    case variable(String)
}

extension Token {
    var isLeftParen: Bool {
        switch self {
            case .leftParen:
                return true
            default:
                return false
        }
    }

    var isRighttParen: Bool {
        switch self {
            case .rightParen:
                return true
            default:
                return false
        }
    }

    var isBinaryOperator: Bool {
        switch self {
            case .binaryOperator(_):
                return true
            default:
                return false
        }
    }

    var isUnaryOperator: Bool {
        switch self {
            case .unaryOperator(_):
                return true
            default:
                return false
        }
    }

    var isNumber: Bool {
        switch self {
            case .number(_):
                return true
            default:
                return false
        }
    }

    var number: Int64? {
        switch self {
            case .number(let num):
                return num
            default:
                return nil
        }
    }

    var isNumberConvertible: Bool {
        switch self {
            case .numberConvertible(_):
                return true
            default:
                return false
        }
    }
}

extension Token: Precedence {
    public var precedence: Int {
        switch self {
            case .leftParen:
                return 0
            case .rightParen:
                return 0
            case .binaryOperator(let op):
                return op.precedence
            case .unaryOperator(let op):
                return op.precedence
            case .number(_), .numberConvertible(_):
                return 0
            case .variable(_):
                return 0
        }
    }
}

extension Token: Equatable {
    public static func == (lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {

            case (leftParen, leftParen):
                return true
            case (rightParen, rightParen):
                return true
            case (binaryOperator(let lop), binaryOperator(let rop)):
                return lop == rop
            case (unaryOperator(let lop), unaryOperator(let rop)):
                return lop == rop
            case (number(let lnum), number(let rnum)):
                return lnum.eval == rnum.eval
            case (variable(let leftVar), variable(let rightVar)):
                return leftVar == rightVar
            default:
                return true
        }
    }
}

extension Token: CustomStringConvertible {
    public var description: String {
        switch self {

            case .leftParen:
                return "("
            case .rightParen:
                return ")"
            case .binaryOperator(let op):
                return String(describing: op)
            case .unaryOperator(let op):
                return String(describing: op)
            case .number(let num):
                return "\(num)"
            case .numberConvertible(let num):
                return "\(num.eval)"
            case .variable(let name):
                return name
        }
    }
}

extension [Token] {
    
    /// convert the array of `Token` containing an infix expression to an array of `Token` as a postfix expression
    /// - Returns: array of `Token` as a postfix expression (assuming `self` contains an infix expression)
    public func infixToPostfix() throws -> [Token] {
        var stack = Stack<Token>()
        var postfix: [Token] = []

        for (idx, token) in self.enumerated() {
            switch token {
                case .leftParen:
                    stack.push(token)

                case .rightParen:
                    // while the stack is not empty, pop and push operands until find left paren
                    while let top = stack.top, !top.isLeftParen {
                        postfix.append(stack.pop()!)
                    }

                    // pop the left paren
                    let leftParen = stack.pop()
                    guard case .leftParen = leftParen else {
                        throw InfixToPostfixError.noMatchingLeftParen(self, idx)
                    }


                    // pop any unary operands from stack and add to postfix expression
                    while !stack.isEmpty {
                        let top = stack.top!
                        if case .unaryOperator(_) = top {
                            postfix.append(stack.pop()!)
                        } else {
                            break
                        }
                    }

                case .binaryOperator(let op):
                    // while stack is not empty, if not left operand or unary operand
                    // and while top item does not have a lower precedence than the token
                    // pop and add that operator to the postfix expression
                    while let top = stack.top, top.precedence >= token.precedence {
                        postfix.append(stack.pop()!)
                    }
                    // now push the token after popping higher precedence operators
                    if op.isPow {
                        // for right to left precedence
                        stack.push(.binaryOperator(.exp))
                    } else {
                        stack.push(token)
                    }
                case .unaryOperator(_):
                    // unary operands are pushed
                    stack.push(token)
                case .number(_), .numberConvertible(_):
                    // numbers are added to postfix expression
                    postfix.append(token)
                case .variable(_):
                    postfix.append(token)
            }
        }

        // add any remaining operators on the stack to the postfix expression
        while let top = stack.pop() {
            postfix.append(top)
        }

        return postfix
    }
    
    /// evaulate the array of `Token` assuming it is a postfix expression
    /// - Returns: result of evaluating the array of Token as a postfix expression
    public func evaluateAsPostfix(variableDictionary: [String: Int64] = [:]) throws -> Int64 {
        var stack = Stack<Int64>()
        for (idx, token) in self.enumerated() {
            switch token {
                // should never have parens in a postfix expression
                case .leftParen:
                    throw PostfixError.containsParenthesis("(", self, idx)

                case .rightParen:
                    throw PostfixError.containsParenthesis(")", self, idx)

                case .binaryOperator(let op):
                    guard let rhs = stack.pop(), let lhs = stack.pop() else {
                        throw PostfixError.binaryOperatorMissingOperands(String(describing: op), self, idx)
                    }
                    stack.push(op.evaluate(lhs: lhs, rhs: rhs))

                case .unaryOperator(let op):
                    guard let num = stack.pop() else {
                        throw PostfixError.unaryOperatorMissingOperand(String(describing: op), self, idx)
                    }
                    stack.push(op.evaluate(value: num))

                case .number(let value):
                    stack.push(value)

                case .numberConvertible(let value):
                    stack.push(value.eval)

                case .variable(let name):
                    guard let num = variableDictionary[name] else { throw PostfixError.missingVariableValue(name) }
                    stack.push(num)
            }
        }
        guard stack.count == 1 else {
            throw PostfixError.notOneValueOnStack(stack.count, self)
        }
        return stack.pop()!
    }
}

// MARK: AllowedToken

public struct AllowedToken: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let digit = AllowedToken(rawValue: 1 << 0)
    static let number = AllowedToken(rawValue: 1 << 1)
    static let numberConvertible = AllowedToken(rawValue: 1 << 2)
    static let variable = AllowedToken(rawValue: 1 << 3)
    static let leftParen = AllowedToken(rawValue: 1 << 4)
    static let rightParen = AllowedToken(rawValue: 1 << 5)
    static let binaryOperator = AllowedToken(rawValue: 1 << 6)
    static let unaryOperator = AllowedToken(rawValue: 1 << 7)
}

// MARK: Equation
public struct Equation {
    var tokens: [Token] = []
    var variableValues: [String: Int64]

    public init?(infixString: String, variableValues: [String: Int64] = [:]) {
        self.variableValues = variableValues
        for ch in infixString {
            guard ch.isASCII else { return nil }
            let allow = allowableTokens
            if ch == "k" {
                addVariable("k")
            } else if let digit = ch.wholeNumberValue {
                if allow.contains(.digit) {
                    addDigit(digit)
                } else { return nil }
            } else if ch == "(" {
                if allow.contains(.leftParen) {
                    addLeftParen()
                } else { return nil }
            } else if ch == ")" {
                if allow.contains(.rightParen) {
                    addRightParen()
                } else { return nil }
            } else if ch == "+" {
                if allow.contains(.binaryOperator) || allow.contains(.unaryOperator) {
                    addOperator(.add)
                }
            } else if ch == "-" {
                let allow = allowableTokens
                if allow.contains(.binaryOperator) || allow.contains(.unaryOperator) {
                    addOperator(.sub)
                } else { return nil }
            } else if ch == "*" {
                if allow.contains(.binaryOperator) {
                    addOperator(.mul)
                } else { return nil }
            } else if ch == "/" {
                if allow.contains(.binaryOperator) {
                    addOperator(.div)
                } else { return nil }
            } else if ch == "%" {
                if allow.contains(.binaryOperator) {
                    addOperator(.mod)
                } else { return nil }
            } else if ch == "^" {
                if allow.contains(.binaryOperator) {
                    addOperator(.pow)
                } else { return nil }
            } else if ch != " " {
                return nil
            }
        }
    }

    public init(tokens: [Token] = [], variableValues: [String: Int64] = [:]) {
        self.variableValues = variableValues
        self.tokens = tokens
    }

    public var allowableTokens: AllowedToken {
        guard let lastToken = tokens.last else {
            return [.digit, .number, .numberConvertible, .variable, .leftParen, .unaryOperator]
        }
        switch lastToken {

            case .leftParen:
                return [.leftParen, .digit, .number, .variable, .numberConvertible, .unaryOperator]

            case .rightParen:
                if unmatchedLeftParenCount > 0 {
                    return [.binaryOperator, .rightParen]
                } else {
                    return [.binaryOperator]
                }

            case .binaryOperator(_):
                return [.leftParen, .digit, .number, .variable, .numberConvertible, .unaryOperator]

            case .unaryOperator(_):
                return [.leftParen, .digit, .number, .variable, .numberConvertible, .unaryOperator]

            case .number(_):
                if unmatchedLeftParenCount > 0 {
                    return [.digit, .binaryOperator, .rightParen]
                } else {
                    return [.digit, .binaryOperator]
                }

            case .numberConvertible(_):
                if unmatchedLeftParenCount > 0 {
                    return [.binaryOperator, .rightParen]
                } else {
                    return [.binaryOperator]
                }

            case .variable(_):
                if unmatchedLeftParenCount > 0 {
                    return [.binaryOperator, .rightParen]
                } else {
                    return [.binaryOperator]
                }
        }
    }

    public mutating func addDigit(_ digit: Int) {
        if let lastToken = tokens.last, let num = lastToken.number {
            tokens.removeLast()
            tokens.append(.number(num * 10 + Int64(digit)))
        } else {
            tokens.append(.number(Int64(digit)))
        }
    }

    public mutating func addNumber(_ num: Int64) {
        tokens.append(.number(num))
    }

    public mutating func addNumberConvertible(_ value: Int64Convertible) {
        tokens.append(.numberConvertible(value))
    }

    public mutating func addVariable(_ name: String) {
        tokens.append(.variable(name))
    }

    public mutating func addOperator(_ op: BinaryOperator) {
        let allowed = allowableTokens
        if allowed.contains(.binaryOperator) {
            tokens.append(.binaryOperator(op))
        } else {
            switch op {
                case .add:
                    tokens.append(.unaryOperator(.plus))
                case .sub:
                    tokens.append(.unaryOperator(.neg))
                default:
                    print("shouldn't happen")
            }
        }
    }

    public mutating func addUnaryOperator(_ op: UnaryOperator) {
        tokens.append(.unaryOperator(op))
    }

    public mutating func addLeftParen() {
        unmatchedLeftParenCount += 1
        tokens.append(.leftParen)
    }

    public mutating func addRightParen() {
        unmatchedLeftParenCount -= 1
        tokens.append(.rightParen)
    }

    public func evaluate(overrideVariable: [String: Int64]? = nil) throws -> Int64 {
        let postfixTokens = try tokens.infixToPostfix()
        let varDict = overrideVariable ?? variableValues
        return try postfixTokens.evaluateAsPostfix(variableDictionary: varDict)
    }

    private var unmatchedLeftParenCount = 0
}
