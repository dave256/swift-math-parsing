//
//  CombinatoricFunctions.swift
//  
//
//  Created by David M Reed on 5/4/24.
//

public func factorial(_ n: Int) -> Int64 {
    (2...Int64(n)).reduce(Int64(1), *)

}

public struct Combinations: Int64Convertible {

    public private(set) var n: Int
    public private(set) var k: Int

    public var eval: Int64 {
        factorial(n) / factorial(k) / factorial(n - k)
    }

    public init(n: Int, k: Int) {
        self.n = n
        self.k = k
    }
}
