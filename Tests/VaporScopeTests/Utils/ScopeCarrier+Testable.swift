//
//  File.swift
//  
//
//  Created by AFuture D on 2022/9/13.
//

import VaporScope
import JWT

public struct User: ScopeCarrier {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case scopes = "scopes"
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    public var scopes: [String]
    
    public func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
    
    public init(
        subject: SubjectClaim,
        expiration: ExpirationClaim,
        scopes: [String]
    ) {
        self.subject = subject
        self.expiration = expiration
        self.scopes = scopes
    }
}

extension User: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.subject == rhs.subject
            && lhs.scopes == rhs.scopes
    }
}


extension User {
    static public func dummy(scope: [String]) -> Self {
        return User (
            subject: .init(value: "02F6A5B7-6AE1-4AED-8CCE-F013163A9AC7"),
            expiration: .init(value: Date.init(timeIntervalSinceNow: 3600)),
            scopes: scope
        )
    }
}
