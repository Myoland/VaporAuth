//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor

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
public struct ScopedRouterBundler<T: ScopeCarrier> {
    let resource: String
    let routes: RoutesBuilder

    @discardableResult
    public func with(action: String, builder: (RoutesBuilder) throws -> ()) rethrows -> Self {
        try builder(routes.grouped(
            T.guardMiddleware(with: Scope(r: resource, a: action).raw)
        ))
        return self
    }

    public func all( builder: (RoutesBuilder) throws -> ()) rethrows {
        try builder(routes.grouped(
            T.guardMiddleware(with: Scope(r: resource, a: Scope.ACTION_SET_MARK).raw)
        ))
    }
}

public extension RoutesBuilder {
    func scoped<T: ScopeCarrier>(
        _ resource: String,
        by carrier: T.Type = T.self,
        builder: (RoutesBuilder) throws -> ()
    ) rethrows -> ScopedRouterBundler<T> {
        try builder(self)
        return ScopedRouterBundler<T>(
            resource: resource,
            routes: self
        )
    }

    func scoped<T: ScopeCarrier>(
        _ resource: String,
        by carrier: T.Type = T.self
    ) -> ScopedRouterBundler<T> {
        return self.scoped(resource, by: carrier) { _ in }
    }
}
