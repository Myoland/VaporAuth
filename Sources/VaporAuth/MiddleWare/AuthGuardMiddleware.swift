//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/18.
//

import Foundation
import Vapor
import JWT


/// Extension for `Authenticatable`
extension JWTPayload where Self: AuthCarrier {
    public static func guardMiddleware (
        _ matcher: [any AuthPredicate<Self>]
    ) -> AuthGuardMiddleware<Self> {
        return AuthGuardMiddleware<Self>(matcher)
    }
    
    public static func guardMiddleware (
        _ matcher: any AuthPredicate<Self>...
    ) -> AuthGuardMiddleware<Self> {
        return AuthGuardMiddleware<Self>(matcher)
    }
}

/// A Middleware for Helping Scope asserting.
public struct AuthGuardMiddleware<T: AuthCarrier>: AsyncMiddleware {
    var matchers: [any AuthPredicate<T>]

    init(_ matchers: [any AuthPredicate<T>]) {
        self.matchers = matchers
    }

    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {

        guard try request.oauth.satisfied(with: self.matchers, as: T.self) else  {
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}
