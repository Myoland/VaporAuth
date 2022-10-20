//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor

/// When a ScopeHolder is created, this means the start of scoping.
///
/// After init, you can do following things:
/// 1. attach resource, but you will need to attach action later.
/// 2. attach scope
/// 3. group path
/// 4. group path with resource
public struct ScopeHolder<T: ScopeCarrier> {
    
    let root: RoutesBuilder
    
    
    /// Example:
    /// ```
    /// holder.with(scope: "a_scope").get(use:)
    /// ```
    @discardableResult
    public func with(
        scope: String
    ) -> RoutesBuilder {
        ScopedRouterBundler<T>(root: root, scope: [scope])
    }
    
    @discardableResult
    public func with(
        resource: String,
        builder: @escaping (ScopeResourceHolder<T>) throws -> ()
    ) rethrows -> Self {
        try builder(ScopeResourceHolder<T>(root: root, resource: resource))
        return self
    }
    
    public func group(
        _ path: PathComponent...,
        configure: @escaping (ScopeHolder<T>) throws -> ()
    ) rethrows {
        try root.grouped(path).scope(by: T.self, builder: configure)
    }
    
    public func group(
        _ path: PathComponent...,
        resource: String,
        configure: @escaping (ScopeResourceHolder<T>) throws -> ()
    ) rethrows {
        try root.grouped(path).scope(resource: resource, by: T.self, configure: configure)
    }
}

extension ScopeHolder {
    
    /// Example:
    /// ```
    /// holder.with(scope: .init(r: "a", a: "b")).get(use:)
    /// ```
    @discardableResult
    public func with(
        scope: Scope
    ) -> RoutesBuilder {
        self.with(scope: scope.raw)
    }
    
    /// Example:
    /// ```
    /// holder.with(resource: "a", action: "b").get(use:)
    /// ```
    @discardableResult
    public func with(
        resource: String,
        action: String
    ) -> RoutesBuilder {
        self.with(scope: .init(r: resource, a: action))
    }
}

/// When a ScopeResourceHolder is created, all you need is attaching action.
///
/// Once action is attached, the scoping is finished, then you can do anything as uaual.
public struct ScopeResourceHolder<T: ScopeCarrier> {
    
    let root: RoutesBuilder
    let resource: String
    
    
    /// Attach action.
    ///
    /// This func indicates the end of scoping.
    ///
    /// Example:
    /// ```
    /// holder.with(action: "a").get(use:)
    /// ```
    @discardableResult
    public func with(
        action: String
    ) -> ScopedRouterBundler<T> {
        ScopedRouterBundler<T>(root: root, scope: [Scope(r: resource, a: action).raw])
    }
    
    /// Helping group paths.
    ///
    /// Sometimes, for coninuing attaching acitons, you need group some paths.
    ///
    /// Example:
    /// ```
    /// holder.group(":id") {
    ///     $0.with(action: "a").get(use:)
    ///     $0.with(action: "b").post(use:)
    /// }
    /// ```
    public func group(
        _ path: PathComponent...,
        configure: @escaping (ScopeResourceHolder<T>) throws -> ()
    ) rethrows {
        try root.grouped(path).scope(resource: resource, by: T.self, configure: configure)
    }
}

public struct ScopedRouterBundler<T: ScopeCarrier>: RoutesBuilder {
    let scope: [String]
    let root: RoutesBuilder
    
    public func add(_ route: Vapor.Route) {
        route.responder = T.guardMiddleware(with: scope).makeResponder(chainingTo: route.responder)
        self.root.add(route)
    }
    
    init(root: RoutesBuilder, scope: [String]) {
        self.scope = scope
        self.root = root
    }
}


/// The sugar for create routes with Scope.
///
/// Notice functions will return Void
public extension RoutesBuilder {
    
    /// This function is used for declaring the start of permissions
    ///
    /// When using the func, you can try to attach resource for routes
    /// by `with(resource:builder:)` or `with(resource:action:)`
    ///
    /// Example:
    ///
    /// ```
    /// routes.scope(by: User.self) {
    ///     $0.with(resource: "a") {
    ///         $0.with(action: "b").get(use:)
    ///     }
    ///     $0.with(resource: "a", action: "b").get(use:)
    /// }
    /// ```
    func scope<T: ScopeCarrier>(
        by carrier: T.Type,
        builder: @escaping (ScopeHolder<T>) throws -> ()
    ) rethrows {
        let helper = ScopeHolder<T>(root: self)
        try builder(helper)
    }
    
    /// This function is used to simplify the checking of scopes.
    ///
    /// Example:
    ///
    /// ```
    /// routes.scope("a_scope", by: User.self) {
    ///     $0.get(use:)
    /// }
    /// ```
    func scope<T: ScopeCarrier>(
        _ scope: String,
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(ScopedRouterBundler<T>(
            root: self, scope: [scope]
        ))
    }
    
    /// This function is used to simplify the checking of scopes.
    ///
    /// Example:
    ///
    /// ```
    /// routes.scope(.init(r: "a", a: "b"), by: User.self) {
    ///     $0.get(use:)
    /// }
    /// ```
    func scope<T: ScopeCarrier>(
        _ scope: Scope,
        by carrier: T.Type,
        builder: @escaping (RoutesBuilder) throws -> ()
    ) rethrows {
        try builder(ScopedRouterBundler<T>(
            root: self, scope: [scope.raw]
        ))
    }
    
    func scope<T: ScopeCarrier>(
        resource: String,
        by carrier: T.Type = T.self,
        configure: @escaping (ScopeResourceHolder<T>) throws -> ()
    ) rethrows {
        try configure(ScopeResourceHolder<T>(
            root: self, resource: resource
        ))
    }
}


/// The sugar for create routes with Scope.
///
/// Like the `grouped(_:)` this func will return RoutesBuilder.
public extension RoutesBuilder {
    
    /// This function is used to simplify the checking of scopes.
    ///
    /// Notice, this func will return RoutesBuilder, and you can do anythin as usual.
    ///
    /// Example:
    ///
    /// ```
    /// routes.scoped(scope: "a_scope", by: User.self)
    ///       .get(use:)
    /// ```
    @discardableResult
    func scoped<T: ScopeCarrier>(
        scope: String,
        by carrier: T.Type
    ) -> ScopedRouterBundler<T> {
        ScopedRouterBundler<T>(
            root: self, scope: [scope]
        )
    }
    
    /// This function is used to simplify the checking of scopes.
    ///
    /// Example:
    ///
    /// ```
    /// routes.scoped(.init(r: "a", a: "b"), by: User.self)
    ///       .get(use:)
    /// ```
    @discardableResult
    func scoped<T: ScopeCarrier>(
        _ scope: Scope,
        by carrier: T.Type
    ) -> ScopedRouterBundler<T> {
        self.scoped(scope: scope.raw, by: carrier)
    }
    
    /// This function is used to simplify the checking of scopes.
    ///
    /// Example:
    ///
    /// ```
    /// routes.scoped(r: "a", a: "b", by: User.self)
    ///       .get(use:)
    /// ```
    @discardableResult
    func scoped<T: ScopeCarrier>(
        r resource: String,
        a action: String,
        by carrier: T.Type
    ) -> ScopedRouterBundler<T> {
        self.scoped(.init(r: resource, a: action), by: carrier)
    }
    
    /// This function is used for declaring the start of
    /// permissions with atttaching resource.
    ///
    /// You can attach action after that.
    ///
    /// ```
    /// routes.scoped(resource: "a")
    ///       .with(action: "b")
    ///       .get(use:)
    /// ```
    @discardableResult
    func scoped<T: ScopeCarrier>(
        resource: String,
        by carrier: T.Type = T.self
    ) -> ScopeResourceHolder<T> {
        ScopeResourceHolder<T>(
            root: self, resource: resource
        )
    }
}


