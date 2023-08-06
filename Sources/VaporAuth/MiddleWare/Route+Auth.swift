//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor

public class AuthBuilder<T> where T: AuthCarrier {
    internal var matchers: [any AuthPredicate<T>] = []
    
    init() {}
    
    @discardableResult
    public func add<U: Guardable> (
        _ keyPath: KeyPath<T, U>,
        _ value: U
    ) -> AuthBuilder<T> {
        let matcher = AuthFieldPredicate(keyPath, value)
        return self.add(matcher)
    }
    
    @discardableResult
    public func add (
        predicate: @escaping (T) -> Bool
    ) -> AuthBuilder<T> {
        let matcher = AuthBasePredicate(closure: predicate)
        return self.add(matcher)
    }
    
    @discardableResult
    public func add(_ matcher: any AuthPredicate<T>) -> AuthBuilder<T> {
        self.matchers.append(matcher)
        return self
    }
    
    internal func build() -> [any AuthPredicate<T>] {
        return matchers
    }
}

public extension RoutesBuilder {
    func grouped<T: AuthCarrier, U: Guardable> (
        _ keyPath: KeyPath<T, U>,
        _ value: U
    ) -> RoutesBuilder {
        let matcher = AuthFieldPredicate(keyPath, value)
        let middleware = T.guardMiddleware(matcher)
        return self.grouped(middleware)
    }
    
    func grouped<T: AuthCarrier> (
        predicate: @escaping (T) -> Bool
    ) -> RoutesBuilder {
        let matcher = AuthBasePredicate(closure: predicate)
        let middleware = T.guardMiddleware(matcher)
        return self.grouped(middleware)
    }
    
    func grouped<T: AuthCarrier> (
        handle: () -> any AuthPredicate<T>
    ) -> RoutesBuilder {
        let matcher = handle() 
        let middleware = T.guardMiddleware(matcher)
        
        return self.grouped(middleware)
    }
}
