//
//  CombinatoricFunctions.swift
//
//
//  Created by David M Reed on 5/4/24.
//

func factorial(_ n: Int) -> Int64 {
    if n < 2 {
        return 1
    } else {
        return (2...Int64(n)).reduce(Int64(1), *)
    }
}

public struct Combinations: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64

    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        if k > n {
            eval = 0
        }
        else if n == k || k == 0 {
            eval = 1
        }
        else if k > n - k {
            let num = (Int64(k+1)...Int64(n)).reduce(1, *)
            eval = num / factorial(n - k)
        } else {
            let num = (Int64(n-k+1)...Int64(n)).reduce(1, *)
            eval = num / factorial(k)
        }
    }
}

public struct Falling: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64

    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        eval = (Int64(n - k + 1)...Int64(n)).reduce(1, *)

    }
}

public struct Multichoose: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        eval = Combinations(n: n + k - 1, k: k).eval
    }
}

public struct MultichooseOnto: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        eval = Combinations(n: k - 1, k: n - 1).eval
    }
}

public struct PermutationsWithRepetition: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        eval = power(Int64(n), Int64(k))
    }
}

public struct Injection: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        if k > n {
            eval = 0
        } else {
            eval = 1
        }
    }
}

public struct OntoFunctions: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        var total: Int64 = 0
        for i in 0...n {
            total = total + power(Int64(i), Int64(k)) * power(-1, Int64(n - i)) * Combinations(n: n, k: i).eval
        }
        eval = total
    }
}

public struct Stirling2: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        eval = OntoFunctions(n: n, k: k).eval / Falling(n: n, k: n).eval
    }
}

public struct MultiStirling2: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        var total = 0
        for i in 1...n {
            total = total + Int(Stirling2(n: i, k: k).eval)
        }
        eval = Int64(total)
    }
}

public struct IntegerPartition: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        var partition: Array<Array<Int64>> = Array(repeating: Array(repeating: 0, count: n), count: k)

        for i in 0..<n {
            for j in 0..<k {
                if i == 0 {
                    partition[j][i] = 1
                } else {
                    if j == 0 {

                    }
                    else if j - i <= 0 {
                        partition[j][i] = partition[j - 1][i - 1]
                    } else {
                        partition[j][i] = partition[j - 1][i - 1] + partition[j - 1 - i][i]
                    }
                }
            }
        }
        eval = partition[k - 1][n - 1]
    }
}

public struct MultiPartition: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        var total = 0
        for i in 1...n {
            total = total + Int(IntegerPartition(n: i, k: k).eval)
        }
        eval = Int64(total)
    }
}

public struct Summation: Int64Convertible {
    public private(set) var start: Int
    public private(set) var end: Int
    public private(set) var equation: Equation
    public private(set) var eval: Int64


    public init?(start: Int, end: Int, equation: Equation) {
        self.start = start
        self.end = end
        self.equation = equation

        eval = 0
        for k in start...end {
            guard let result = try? equation.evaluate(overrideVariable: ["k": Int64(k)]) else { return nil }
            eval += result
        }
    }
}

public enum Kind: String, Identifiable, CaseIterable {
    case different
    case alike

    public var id: Self { self }
}
public enum DistributionType: String, Identifiable, CaseIterable {
    case any
    case oneToOne = "1-1"
    case onto

    public var id: Self { self }
}

public func twelveFold(n: Int, k: Int, balls: Kind, boxes: Kind, distribution: DistributionType) -> Int64Convertible {

    switch (balls, boxes, distribution) {

        case (.alike, .alike, .any):
            return MultiPartition(n: n, k: k)
        case (.alike, .alike, .oneToOne):
            return Injection(n: n, k: k)
        case (.alike, .alike, .onto):
            return IntegerPartition(n: n, k: k)

        case (.alike, .different, .any):
            return Multichoose(n: n, k: k)
        case (.alike, .different, .oneToOne):
            return Combinations(n: n, k: k)
        case (.alike, .different, .onto):
            return MultichooseOnto(n: n, k: k)

        case (.different, .alike, .any):
            return MultiStirling2(n: n, k: k)
        case (.different, .alike, .oneToOne):
            return Injection(n: n, k: k)
        case (.different, .alike, .onto):
            return Stirling2(n: n, k: k)

        case (.different, .different, .any):
            return PermutationsWithRepetition(n: n, k: k)
        case (.different, .different, .oneToOne):
            return Falling(n: n, k: k)
        case (.different, .different, .onto):
            return OntoFunctions(n: n, k: k)

    }

}
