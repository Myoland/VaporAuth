//
//  File.swift
//  
//
//  Created by AFuture D on 2022/9/6.
//

import Foundation

/// A Struct for wrapping different Scope types.
/// And provide consistent operations.
struct ScopeWrapper {
    let scope: Scope?
    let raw: String
    init(raw: String) {
        self.raw = raw
        self.scope = Scope(raw: raw)
    }
}

extension ScopeWrapper: Equatable {
    static func == (lhs: ScopeWrapper, rhs: ScopeWrapper) -> Bool {
        if let ls = lhs.scope, let rs = rhs.scope {
            return ls == rs
        }
        return lhs.raw == rhs.raw
    }
    
    static func <= (lhs: ScopeWrapper, rhs: ScopeWrapper) -> Bool {
        if let ls = lhs.scope, let rs = rhs.scope {
            return ls <= rs
        }
        return lhs.raw == rhs.raw
    }
    
    static func >= (lhs: ScopeWrapper, rhs: ScopeWrapper) -> Bool {
        if let ls = lhs.scope, let rs = rhs.scope {
            return ls >= rs
        }
        return lhs.raw == rhs.raw
    }
}
