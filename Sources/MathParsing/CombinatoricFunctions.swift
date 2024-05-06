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
