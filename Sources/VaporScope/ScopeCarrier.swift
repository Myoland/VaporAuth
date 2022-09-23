//
//  File.swift
//  
//
//  Created by AFuture D on 2022/9/13.
//

import Vapor
import JWT


/// Example:
/// ```
/// public struct User: ScopeCarrier {
///   public var subject: SubjectClaim
///   public var expiration: ExpirationClaim
///   public var scopes: [String]
///
///   public func verify(using signer: JWTSigner) throws {
///       try self.expiration.verifyNotExpired()
///   }
/// }
///
/// let user = User(...)
/// try await User.authenticator().authenticate(jwt: user, for: request)
///
/// or
///
/// let user = User(...)
/// try await user.authenticate(request: request)
/// ```
public protocol ScopeCarrier: JWTPayload, Authenticatable {
    var scopes: [String] { get }
}

extension ScopeCarrier {
    public static func authenticator() -> ScopeCarrierAuthenticator<Self> {
        ScopeCarrierAuthenticator<Self>()
    }
    
    func authenticate(request: Request) async throws {
        request.auth.login(self)
    }
}

public struct ScopeCarrierAuthenticator<Payload>: AsyncJWTAuthenticator
    where Payload: ScopeCarrier
{
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try request.jwt.verify(as:Payload.self)
        try await self.authenticate(jwt: payload, for: request)
        
        return try await next.respond(to: request)
    }
    
    // This method can be directly called.
    // But, When you call `ScopeCarrier.authenticator.authenticate(request:)`
    // this method will be called by AsyncJWTAuthenticator.
    public func authenticate(jwt: Payload, for request: Request) async throws {
        try await jwt.authenticate(request: request)
    }
}
