//
//  File.swift
//
//
//  Created by AFuture D. on 2022/7/19.
//

@testable import VaporScope
import Vapor
import Foundation
import XCTest

final class ScopeHelperTests: XCTestCase {
    
    var app: Application!
    
    // Runs before each test method
    override func setUp() async throws {
        app = Application(.testing)
        try app.jwt.signers.use(jwk: JWTHelper.jwkPrivate, isDefault: true)
        try app.jwt.signers.use(jwk: JWTHelper.jwk)
    }
    
    // Runs after each test method
    override func tearDown() async throws {
        app.shutdown()
    }
    
    func testJWKLoad() async throws {
        
        let u = User.dummy(scope: ["all.part:read"])
        let encoded = try app.jwt.signers.sign(u)
        
        let decoded = try app.jwt.signers.verify(encoded, as: User.self)
        
        XCTAssertEqual(decoded, u)
    }
    
    func testScopeHelperMissPayload() async throws {

        app.routes.grouped([
            User.guardMiddleware(with: "")
        ]).get("test") { req -> HTTPStatus in
            return .ok
        }

        // if request do not have paylod
        try app.test(.GET, "test") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }

    func testScopeHelperSingleScope() async throws {

        app.routes.grouped([
            // identical to ScopeHelper<User>(["one"])
            User.guardMiddleware(with: "one")
        ]).get("one") { req -> HTTPStatus in
            return .ok
        }

        app.routes.grouped([
            User.guardMiddleware(with: "two")
        ]).get("two") { req -> HTTPStatus in
            return .ok
        }

        let u = User.dummy(scope: ["one"])
        let encoded = try app.jwt.signers.sign(u)

        // if payload's scopes do not contain the required scope
        try app.test(.GET, "two", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }

        try app.test(.GET, "one", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

    func testScopeEnsureMiddlewareMutiScope() async throws {

        app.routes.grouped([
            User.guardMiddleware(with: "one")
        ]).get("one") { req -> HTTPStatus in
            return .ok
        }

        app.routes.grouped([
            User.guardMiddleware(with: ["one", "two"])
        ]).get("two") { req -> HTTPStatus in
            return .ok
        }

        app.routes.grouped([
            User.guardMiddleware(with: ["one", "two", "three"])
        ]).get("three") { req -> HTTPStatus in
            return .ok
        }

        let u = User.dummy(scope: ["one", "two"])
        let encoded = try app.jwt.signers.sign(u)

        try app.test(.GET, "one", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }

        try app.test(.GET, "two", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }

        // if payload's scopes not reach the required scope
        try app.test(.GET, "three", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
}
