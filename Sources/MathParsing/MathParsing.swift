public protocol Int64Convertible {
    var eval: Int64 { get }
}

extension Int: Int64Convertible {
    public var eval: Int64 { Int64(self) }
}

extension Int64: Int64Convertible {
    public var eval: Int64 { self }
}

public enum BinaryOperator: Equatable {
    case add
    case sub
    case mul
    case div
    case mod
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
        }
    }
}

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
}

public enum Token {
    case leftParen
    case rightParen
    case binaryOperator(BinaryOperator)
    case unaryOperator(UnaryOperator)
    case number(Int64Convertible)

    var precedence: Int {
        switch self {
            case .leftParen:
                return 0
            case .rightParen:
                return 0
            case .binaryOperator(let binaryOperator):
                switch binaryOperator {
                    case .add:
                        return 1
                    case .sub:
                        return 1
                    case .mul:
                        return 2
                    case .div:
                        return 2
                    case .mod:
                        return 2
                }
            case .unaryOperator(_):
                return 3
            case .number(_):
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
                return "\(num.eval)"
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
                    while !stack.isEmpty {
                        let top = stack.top!
                        if case .leftParen = top { break }
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

                case .binaryOperator(_):
                    // while stack is not empty, if not left operand or unary operand
                    // and while top item does not have a lower precedence than the token
                    // pop and add that operator to the postfix expression
                    while !stack.isEmpty {
                        let top = stack.top!
                        if case .leftParen = top { break }
                        if case .unaryOperator(_) = top { break }
                        if top.precedence < token.precedence {
                            break
                        }
                        postfix.append(stack.pop()!)
                    }
                    // now push the token after popping higher precedence operators
                    stack.push(token)
                case .unaryOperator(_):
                    // unary operands are pushed
                    stack.push(token)
                case .number(_):
                    // numbers are added to postfix expression
                    postfix.append(token)
            }
        }

        // add any remaining operators on the stack to the postfix expression
        while !stack.isEmpty {
            postfix.append(stack.pop()!)
        }

        return postfix
    }
    
    /// evaulate the array of `Token` assuming it is a postfix expression
    /// - Returns: result of evaluating the array of Token as a postfix expression
    public func evaluateAsPostfix() throws -> Int64 {
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
                    stack.push(value.eval)
            }
        }
        guard stack.count == 1 else {
            throw PostfixError.notOneValueOnStack(stack.count, self)
        }
        return stack.pop()!
    }
}