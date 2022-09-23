//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/18.
//

import Foundation
import Vapor
import JWT


// Extension for `Authenticatable`
extension ScopeCarrier {
    public static func guardMiddleware(
        with scopes: [String]
    ) -> ScopeGuardMiddleware<Self> {
        return ScopeGuardMiddleware<Self>(scopes)
    }
    
    public static func guardMiddleware(
        with scope: String
    ) -> ScopeGuardMiddleware<Self> {
        return self.guardMiddleware(with: [scope])
    }
}

/// A Middleware for Helping Scope asserting.
public struct ScopeGuardMiddleware<T: ScopeCarrier>: AsyncMiddleware {
    var scopes: [String]

    init(_ scopes: [String]) {
        self.scopes = scopes
    }
    
    init(scope: String) {
        self.init([scope])
    }
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        // Try Login User First
        try await T.authenticator().authenticate(request: request)
        
        guard try request.oauth.satisfied(with: self.scopes, as: T.self) else  {
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}
