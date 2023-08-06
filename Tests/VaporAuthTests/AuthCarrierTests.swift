//
//  File.swift
//
//
//  Created by AFuture D. on 2022/7/19.
//

@testable import VaporScope
import Vapor
import XCTVapor
import JWT

final class AuthCarrierTests: XCTestCase {

   var app: Application!

   override func setUp() async throws {
       app = Application(.testing)
       try app.jwt.signers.use(jwk: JWTHelper.jwkPrivate, isDefault: true)
       try app.jwt.signers.use(jwk: JWTHelper.jwk)
   }

   override func tearDown() async throws {
       app.shutdown()
   }

    func testCarrierEncode() async throws {
        let u = User.dummy(scope: ["all.part:read"])

        let encoded = try app.jwt.signers.sign(u)
        let request = Request(application: app, on: app.eventLoopGroup.next())

        request.headers.bearerAuthorization = BearerAuthorization(token: encoded)

        let payload = try request.jwt.verify(as:User.self)
        XCTAssertEqual(u, payload)
    }

    func testAuthenticator() async throws {
        let u = User.dummy(scope: ["all.part:read"])
        let encoded = try app.jwt.signers.sign(u)
        
        app.routes.grouped(User.authenticator()).get("") { req -> HTTPStatus in
            try req.auth.require(User.self)
            return .ok
        }
        
        try app.test(.GET, "") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
        
        try app.test(.GET, "", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
    
    func testCustomAuthenticator() async throws {
        struct CustomAuthenticator: AsyncJWTAuthenticator {
            typealias Payload = User
            
            func authenticate(jwt: User, for request: Request) async throws {
                if jwt.scope.value.isEmpty {
                    return 
                }
                request.auth.login(jwt)
            }
        }
        
        app.routes.grouped(CustomAuthenticator()).get("") { req -> HTTPStatus in
            try req.auth.require(User.self)
            return .ok
        }
        
        let u = User.dummy(scope: ["all.part:read"])
        let encoded = try app.jwt.signers.sign(u)
        
        try app.test(.GET, "", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
        
        
        let v = User.dummy(scope: [])
        let encodedV = try app.jwt.signers.sign(v)
        
        try app.test(.GET, "", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: encodedV)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
        })
    }


    func testGuardMiddleware() async throws {
        app.grouped(User.authenticator(), User.guardMiddleware()).on(.GET, "login") { req -> HTTPStatus in
            return .ok
        }

        let u = User.dummy(scope: ["all.part:read"])
        let encoded = try app.jwt.signers.sign(u)

        try app.testable(method: .running).test(.GET, "login", beforeRequest: { request in
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .unauthorized)
        })

        try app.testable(method: .running).test(.GET, "login", beforeRequest: { request in
            request.headers.bearerAuthorization = BearerAuthorization(token: encoded)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }
}
