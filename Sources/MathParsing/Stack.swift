//
//  Stack.swift
//
//
//  Created by David M Reed on 5/4/24.
//

import Foundation

public struct Stack<T> {

    mutating public func push(_ item: T) {
        items.append(item)
    }

    public var top: T? {
        items.last
    }

    mutating public func pop() -> T? {
        items.popLast()
    }

    public var isEmpty: Bool {
        items.count == 0
    }

    public var count: Int { 
        items.count
    }

    private var items: [T] = []
}
