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
}

public enum UnaryOperator: Equatable {
    case plus
    case neg
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

public enum Token {
    case leftParen
    case rightParen
    case binaryOperator(BinaryOperator)
    case unaryOperator(UnaryOperator)
    case number(Int64Convertible)

    var priority: Int {
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



public struct MathExpression {
    //var infixString: String = ""
    var infixTokens: [Token] = []

    public init(infixTokens: [Token]) {
        self.infixTokens = infixTokens
    }

//    public init(infixString: String) {
//        self.infixString = infixString
//    }

    func postfixTokens() -> [Token] {
        var stack = Stack<Token>()
        var postfix: [Token] = []

        for token in infixTokens {
            switch token {
                case .leftParen:
                    stack.push(token)
                case .rightParen:
                    while !stack.isEmpty {
                        let top = stack.top!
                        if case .leftParen = top { break }
                        postfix.append(stack.pop()!)
                    }
                    
                    // pop the left paren
                    let _ = stack.pop()

                    while !stack.isEmpty {
                        let top = stack.top!
                        if case .unaryOperator(_) = top {
                            postfix.append(stack.pop()!)
                        } else {
                            break
                        }
                    }
                case .binaryOperator(_):
                    while !stack.isEmpty {
                        let top = stack.top!
                        if case .leftParen = top { break }
                        if case .unaryOperator(_) = top { break }
                        if top.priority < token.priority {
                            break
                        }
                        postfix.append(stack.pop()!)
                    }
                    stack.push(token)
                case .unaryOperator(_):
                    stack.push(token)
                case .number(_):
                    postfix.append(token)
            }
        }

        while !stack.isEmpty {
            postfix.append(stack.pop()!)
        }

        return postfix
    }
}
