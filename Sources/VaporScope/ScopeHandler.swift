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
        typealias Value = ScopeHandler
    }

    public var oauth: ScopeHandler {
        if let existing = storage[Key.self] {
            return existing
        }

        let handler = ScopeHandler(request: self)
        storage[Key.self] = handler

        return handler
    }
}

/// A Handler for helping asserting scopes.
///
/// `ScopeHandler` is always accompanied by a Request.
/// A convenient way to access `ScopeHandler` is to call `request.oauth`.
public class ScopeHandler {
    
    weak var request: Request?
    
    init(request: Request?) {
        self.request = request
    }
    
    func satisfied<T: ScopeCarrier>(with required: [String], as payload: T.Type = T.self) throws -> Bool {
        let payload  = try self.getPayLoad(as: payload)
        let carried = payload.scopes
        return self.assertScopes(required, carried: carried)
    }
    
    
    /// Basic logic for asserting Scopeps.
    ///
    /// Note: Every required scopes should be contained by carried scopes.
    /// `Contained` means a requied scope should satisified by one of the carried scopes.
    func assertScopes(_ required: [String], carried: [String]) -> Bool {
        
        // In our implement, we use `Scope` for better scope calculation.
        // But, we also need take `String` into consideration,
        // so we use `ScopeWrapper` to provider consistent operations.
        let carriedWrappers  = carried.map { ScopeWrapper(raw: $0) }
        let requiredWrappers = required.map { ScopeWrapper(raw: $0) }
        
        for require in requiredWrappers {
            // Notice: When we want to customize basic assert logic,
            // all we need is just make the `predicate` customizable.
            guard carriedWrappers.contains(where: { require <= $0 }) else  {
                return false
            }
        }
        return true
    }
    
    /// Method for getting Payload.
    ///
    /// This method require `request.auth.login(_)` first.
    func getPayLoad<T: ScopeCarrier>(as payload: T.Type = T.self) throws -> T {
        guard let request = self.request else {
            throw Abort(.unauthorized)
        }
        guard let payload = request.auth.get(T.self) else {
            throw Abort(.unauthorized)
        }
        return payload
    }
}
