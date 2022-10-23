//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor


public struct ScopedRouterBundler<T: ScopeCarrier>: RoutesBuilder {
    let scopes: [String]
    let root: RoutesBuilder
    
    public func add(_ route: Vapor.Route) {
        route.responder = T.guardMiddleware(with: scopes).makeResponder(chainingTo: route.responder)
        self.root.add(route)
    }
    
    init(root: RoutesBuilder, scopes: [String]) {
        self.scopes = scopes
        self.root = root
    }
}


public extension RoutesBuilder {
    
    func scope<T: ScopeCarrier>(
        scopes: [String],
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(self.scoped(scopes: scopes, by: carrier))
    }
    
    func scope<T: ScopeCarrier>(
        scopes: [Scope],
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(self.scoped(scopes: scopes.map {$0.raw}, by: carrier))
    }
    
    func scope<T: ScopeCarrier>(
        scope: String,
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(self.scoped(scopes: [scope], by: carrier))
    }
    
    func scope<T: ScopeCarrier>(
        scope: Scope,
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(self.scoped(scope: scope.raw, by: carrier))
    }
    
    func scope<T: ScopeCarrier>(
        resource: String,
        action: String,
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(self.scoped(scope: .init(resource:resource, action: action), by: carrier))
    }
    
}


public extension RoutesBuilder {
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        scopes: [String],
        by carrier: T.Type
    ) -> RoutesBuilder {
        return ScopedRouterBundler<T>(root: self, scopes: scopes)
    }
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        scope: String,
        by carrier: T.Type
    ) -> RoutesBuilder {
        return self.scoped(scopes: [scope], by: carrier)
    }
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        scopes: [Scope],
        by carrier: T.Type
    ) -> RoutesBuilder {
        return self.scoped(scopes: scopes.map {$0.raw}, by: carrier)
    }
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        scope: Scope,
        by carrier: T.Type
    ) -> RoutesBuilder {
        return self.scoped(scope: scope.raw, by: carrier)
    }
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        resource: String,
        action: String,
        by carrier: T.Type
    ) -> RoutesBuilder {
        return self.scoped(scope: .init(resource: resource, action: action), by: carrier)
    }
}

