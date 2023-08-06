//
//  File.swift
//  
//
//  Created by AFuture D on 2022/9/13.
//

import Foundation
import JWTKit
import JWT
import Vapor

/// A `AuthCarrier` carries some infomations that may used for asserting auth.
///
/// Example:
/// ```
/// public struct User: AuthCarrier {
///     enum CodingKeys: String, CodingKey { ... }
///
///     var subject: SubjectClaim
///     var scope: ScopeClaim
///
///     public init(
///         subject: SubjectClaim,
///         scope: ScopeClaim
///     ) { ... }
/// }
/// ```
/// the same as:
/// ```
/// public struct User: JWTPayload & Authenticatable {
///     enum CodingKeys: String, CodingKey { ... }
///
///     var subject: SubjectClaim
///     var scope: ScopeClaim
///
///     public init(
///         subject: SubjectClaim,
///         scope: ScopeClaim
///     ) { ... }
/// }
/// ```
public typealias AuthCarrier = JWTPayload & Authenticatable


public extension JWTPayload where Self: Authenticatable  {
    
    /// The entrance for asserting auth.
    ///
    /// All the predicate should be
    func hasAuth(
        matchers: [any AuthPredicate<Self>]
    ) -> Bool {
        for matcher in matchers {
            guard matcher.hasAuth(carrier: self) else {
                return false
            }
        }
        return true
    }
}
