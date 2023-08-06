//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/19.
//

import Foundation
import Vapor
import JWT

extension Request {
    struct Key: StorageKey {
        typealias Value = AuthHandler
    }

    public var oauth: AuthHandler {
        if let existing = storage[Key.self] {
            return existing
        }

        let handler = AuthHandler(request: self)
        storage[Key.self] = handler

        return handler
    }
}

/// A Handler for helping asserting scopes.
///
/// `AuthHandler` is always accompanied by a Request.
/// A convenient way to access `AuthHandler` is to call `request.oauth`.
public class AuthHandler {

    weak var request: Request?

    init(request: Request?) {
        self.request = request
    }

    func satisfied<T: AuthCarrier>(with matchers: [any AuthPredicate<T>], as payload: T.Type = T.self) throws -> Bool {
        let payload  = try self.requirePayLoad(as: payload)
        
        return payload.hasAuth(matchers: matchers)
    }

    /// Method for getting Payload.
    ///
    /// This method require `request.auth.login(_)` first.
    func requirePayLoad<T: AuthCarrier>(as payload: T.Type = T.self) throws -> T {
        guard let request = self.request else {
            throw Abort(.unauthorized)
        }
        return try request.auth.require(T.self)
    }
}
