//
//  File.swift
//
//
//  Created by AFuture D. on 2022/7/19.
//

@testable import VaporScope
import Vapor
import XCTVapor

final class ScopeCarrierTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        app = Application(.testing)
        try app.jwt.signers.use(jwk: JWTHelper.jwkPrivate, isDefault: true)
        try app.jwt.signers.use(jwk: JWTHelper.jwk)
    }
    
    override func tearDown() async throws {
        app.shutdown()
    }
    
    func testCarrierLogin_A() async throws {
        // scope
        let u = User.dummy(scope: ["all.part:read"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        XCTAssertNotNil(request.auth.get(User.self))
    }
    
    func testCarrierLogin_B() async throws {
        // scope
        let u = User.dummy(scope: ["all.part:read"])
        
        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await u.authenticate(request: request)
        
        XCTAssertNotNil(request.auth.get(User.self))
    }
    
    func testCarrierEncode() async throws {
        let u = User.dummy(scope: ["all.part:read"])

        let encoded = try app.jwt.signers.sign(u)
        let request = Request(application: app, on: app.eventLoopGroup.next())
        
        request.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        
        let payload = try request.jwt.verify(as:User.self)
        XCTAssertEqual(u, payload)
        
        try await User.authenticator().authenticate(jwt: payload, for: request)
        XCTAssertNotNil(request.auth.get(User.self))
    }
    
    func testAuthenticatorMiddleware() async throws {
        app.group(User.authenticator()) {
            $0.on(.GET, "login") { req -> HTTPStatus in
                XCTAssertNotNil(req.auth.get(User.self))
                return .ok
            }
            
            $0.on(.GET, "nope") { req -> HTTPStatus in
                XCTAssertNotNil(req.auth.get(User.self))
                return .ok
            }
        }
        
        let u = User.dummy(scope: ["all.part:read"])
        let encoded = try app.jwt.signers.sign(u)
        
        try app.testable(method: .running).test(.GET, "login", beforeRequest: { request in
            request.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
                                                
        try app.testable(method: .running).test(.GET, "nope", beforeRequest: { request in
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .unauthorized)
        })
    }
    
}
