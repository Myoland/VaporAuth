//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor


public struct ScopeHolder<T: ScopeCarrier> {
    
    let root: RoutesBuilder

    @discardableResult
    public func with(
        resource: String,
        builder: @escaping (ScopeResourceHolder<T>) throws -> ()
    ) rethrows -> Self {
        try builder(ScopeResourceHolder<T>(root: root, resource: resource))
        return self
    }
    
    @discardableResult
    public func with(
        resource: String,
        action: String
    ) -> RoutesBuilder {
        ScopedRouterBundler<T>(root: root, resource: resource, action: action)
    }
    
    public func group(_ path: PathComponent..., configure: (ScopeHolder<T>) throws -> ()) rethrows {
        try root.grouped(path).scope(by: T.self, builder: configure)
    }
}

public struct ScopeResourceHolder<T: ScopeCarrier> {
    
    let root: RoutesBuilder
    let resource: String
    
    @discardableResult
    public func with(
        action: String
    ) -> ScopedRouterBundler<T> {
        ScopedRouterBundler<T>(root: root, resource: resource, action: action)
    }
    
    public func group(_ path: PathComponent..., configure: (ScopeResourceHolder<T>) throws -> ()) rethrows {
        try configure(root.grouped(path).scoped(resource, by: T.self))
    }
}

/// The sugar for create routes with Scoped MiddleWare
///
/// Example:
/// routes.grouped("path").scoped("resource") { routes in
///     routes.scoped("subSourece")
///         .with(action: "a") {
///             $0.get(":id", use: ...)
///         }
/// }
/// .with(action: "A") { writeAction in
///     writeAction.post(use: ...)
/// }
/// .all { allAction in
///     allAction.delete(":id", use: ...)
/// }
public struct ScopedRouterBundler<T: ScopeCarrier>: RoutesBuilder {
    let resource: String
    let action: String
    let root: RoutesBuilder
    
    public func add(_ route: Vapor.Route) {
        route.responder = T.guardMiddleware(with: [Scope(r: resource, a: action).raw]).makeResponder(chainingTo: route.responder)
        self.root.add(route)
    }
    
    init(root: RoutesBuilder, resource: String, action: String) {
        self.resource = resource
        self.action = action
        self.root = root
    }
    
//
//
//    @discardableResult
//    public func scoped(
//        _ resource: String,
//        builder: (RoutesBuilder) throws -> ()
//    ) rethrows -> ScopedRouterBundler<T> {
//        try builder(routes)
//        return ScopedRouterBundler<T>(
//            resource: resource,
//            routes: routes
//        )
//    }
//
//
//
//
//    @discardableResult
//    public func scoped(
//        _ resource: String
//    ) -> ScopedRouterBundler<T> {
//        return self.scoped(resource) { _ in }
//    }
//
//    @discardableResult
//    public func with(action: String, builder: (RoutesBuilder) throws -> ()) rethrows -> Self {
//        try builder(root.grouped(
//            T.guardMiddleware(with: Scope(r: resource, a: action).raw)
//        ))
//        return self
//    }
//
//    public func all( builder: (RoutesBuilder) throws -> ()) rethrows {
//        try builder(root.grouped(
//            T.guardMiddleware(with: Scope(r: resource, a: Scope.ACTION_SET_MARK).raw)
//        ))
//    }
}

public extension RoutesBuilder {
    
    @discardableResult
    func scope<T: ScopeCarrier>(
        by carrier: T.Type,
        builder: (ScopeHolder<T>) throws -> ()
    ) rethrows -> Self {
        let helper = ScopeHolder<T>(root: self)
        try builder(helper)
        return self
    }
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        _ resource: String,
        by carrier: T.Type,
        builder: (RoutesBuilder) throws -> ()
    ) rethrows -> ScopeResourceHolder<T> {
        try builder(self)
        return ScopeResourceHolder<T>(
            root: self, resource: resource
        )
    }
    
    @discardableResult
    func scoped<T: ScopeCarrier>(
        _ resource: String,
        by carrier: T.Type = T.self
    ) -> ScopeResourceHolder<T> {
        return self.scoped(resource, by: carrier) { _ in }
    }
}
