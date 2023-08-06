//
//  File.swift
//  
//
//  Created by 尼诺 on 2023/7/28.
//

import Foundation


public func && <T: AuthCarrier, U: Guardable, V: Guardable> (
    lhs: AuthFieldPredicate<T, U>,
    rhs: AuthFieldPredicate<T, V>
) -> any AuthPredicate<T> {
    lhs.and(other: rhs)
}

public func && <T: AuthCarrier, U: Guardable> (
    lhs: AuthFieldPredicate<T, U>,
    rhs: any AuthPredicate<T>
) -> any AuthPredicate<T> {
    lhs.and(other: rhs)
}

public func && <T: AuthCarrier, U: Guardable> (
    lhs: any AuthPredicate<T>,
    rhs: AuthFieldPredicate<T, U>
) -> any AuthPredicate<T> {
    lhs.and(other: rhs)
}

public func || <T: AuthCarrier, U: Guardable, V: Guardable> (
    lhs: AuthFieldPredicate<T, U>,
    rhs: AuthFieldPredicate<T, V>
) -> any AuthPredicate<T> {
    lhs.or(other: rhs)
}

public func || <T: AuthCarrier, U: Guardable> (
    lhs: AuthFieldPredicate<T, U>,
    rhs: any AuthPredicate<T>
) -> any AuthPredicate<T> {
    lhs.or(other: rhs)
}

public func || <T: AuthCarrier, U: Guardable> (
    lhs: any AuthPredicate<T>,
    rhs: AuthFieldPredicate<T, U>
) -> any AuthPredicate<T> {
    lhs.or(other: rhs)
}

public struct AuthFieldPredicate<Carrier, Field>: AuthPredicate where Carrier: AuthCarrier, Field: Guardable {
    
    public typealias T = Carrier
    
    public var path: KeyPath<Carrier, Field>
    public let value: Field
    
    public init(
        _ lhs: KeyPath<Carrier, Field>,
        _ rhs: Field
    ) {
        self.path = lhs
        self.value = rhs
    }
    
    public func hasAuth(carrier: T) -> Bool {
        let carried = carrier[keyPath: self.path]
        return carried.hasAuth(required: self.value)
    }
}