//
//  CombinatoricFunctions.swift
//
//
//  Created by David M Reed on 5/4/24.
//

func factorial(_ n: Int) -> Int64 {
    (2...Int64(n)).reduce(Int64(1), *)
}

public struct Combinations: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64

    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        if k > n - k {
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
        var total = 0
        for i in 1...n {
            total = total + Int(power(Int64(i), Int64(n)) * power(-1, Int64(n - i)) * Combinations(n: n, k: i).eval)
        }
        eval = Int64(total)
    }
}

public struct Stirling2: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int
    public private(set) var eval: Int64
    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
        eval = OntoFunctions(n: n, k: k).eval * Falling(n: n, k: n).eval
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
                    if j - i < 0 {
                        partition[j][i] = partition[j - 1][i - 1]
                    } else if j != 0 {
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
        for i in 1...k {
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
