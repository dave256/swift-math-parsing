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
