//
//  File.swift
//  
//
//  Created by AFuture D on 2022/9/13.
//

import VaporAuth
import JWT
import Foundation

public struct User: AuthCarrier {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case scope = "scope"
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var scope: ScopeClaim
    
    public func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
    
    public init(
        subject: SubjectClaim,
        expiration: ExpirationClaim,
        scope: ScopeClaim
    ) {
        self.subject = subject
        self.expiration = expiration
        self.scope = scope
    }
}

extension User: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.subject == rhs.subject
            && lhs.scope == rhs.scope
    }
}


extension User {
    static public func dummy(scope: ScopeClaim) -> Self {
        return User (
            subject: .init(value: "02F6A5B7-6AE1-4AED-8CCE-F013163A9AC7"),
            expiration: .init(value: Date.init(timeIntervalSinceNow: 3600)),
            scope: scope
        )
    }
}
