//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor

public extension Route {
    
    func scope<T: ScopeCarrier>(
        with scopes: [String],
        by carrier: T.Type
    ) -> Route {
        self.responder = carrier.guardMiddleware(with: scopes).makeResponder(chainingTo: self.responder)
        return self
    }
    
    @discardableResult
    func scope<T: ScopeCarrier>(
        _ scopes: String...,
        by carrier: T.Type
    ) -> Route {
        return self.scope(with: scopes, by: carrier)
    }
    
    @discardableResult
    func scope<T: ScopeCarrier>(
        with scope: String,
        by carrier: T.Type
    ) -> Route {
        return self.scope(with: [scope], by: carrier)
    }
    
    @discardableResult
    func scope<T: ScopeCarrier>(with scopes: [Scope], by carrier: T.Type = T.self) -> Route {
        return self.scope(with: scopes.map {$0.rawValue}, by: carrier)
    }
    
    @discardableResult
    func scope<T: ScopeCarrier>(
        _ scopes: Scope...,
        by carrier: T.Type
    ) -> Route {
        return self.scope(with: scopes, by: carrier)
    }
    
    @discardableResult
    func scope<T: ScopeCarrier>(
        with scope: Scope,
        by carrier: T.Type
    ) -> Route {
        return self.scope(with: scope.rawValue, by: carrier)
    }
    
    
}
