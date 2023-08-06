//
//  File.swift
//
//
//  Created by AFuture D. on 2022/7/19.
//

@testable import VaporScope
import Vapor
import XCTVapor

final class AuthHandlerTests: XCTestCase {

    var app: Application!

    override func setUp() async throws {
        app = Application(.testing)
        try app.jwt.signers.use(jwk: JWTHelper.jwkPrivate, isDefault: true)
        try app.jwt.signers.use(jwk: JWTHelper.jwk)
    }

    override func tearDown() async throws {
        app.shutdown()
    }
    
    func testMissRequest() async throws {
        
        XCTAssertThrowsError(
            try AuthHandler(request: nil).requirePayLoad(as: User.self)
        ) { error in
            XCTAssertEqual((error as? AbortError)?.status, .unauthorized)
        }
    }
    
    func testMissPayload() async throws {
        let request = Request(application: app, on: app.eventLoopGroup.next())

        XCTAssertThrowsError(
            try AuthHandler(request: request).requirePayLoad(as: User.self)
        ) { error in
            XCTAssertEqual((error as? AbortError)?.status, .unauthorized)
        }


        XCTAssertThrowsError(
            try AuthHandler(request: request).satisfied(with: [], as: User.self)
        ) { error in
            XCTAssertEqual((error as? AbortError)?.status, .unauthorized)
        }
    }

    func testGetPayload() async throws {
        // scope
        let u = User.dummy(scope: ["all.part:read"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        request.auth.login(u)

        XCTAssertEqual(
            try AuthHandler(request: request).requirePayLoad(as: User.self).subject.value,
            u.subject.value
        )
    }

    func testPredicate() async throws {
        
        let u = User.dummy(scope: ["one", "two"])
        
        let request = Request(application: app, on: app.eventLoopGroup.next())
        request.auth.login(u)
        
        XCTAssertNoThrow(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { _ in true})], as:User.self)
        )

        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in 
                !carrier.scope.value.isEmpty
            })], as: User.self)
        )

        XCTAssertFalse(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope.value.contains("any")
            })], as: User.self)
        )
        
        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope.value.contains("one")
            })], as: User.self)
        )
        
        XCTAssertFalse(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope == "one"
            })], as: User.self)
        )
        
        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope == "one two"
            })], as: User.self)
        )
        
        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope.value.contains("one")
            }) || AuthBasePredicate(closure: { carrier in
                carrier.scope.value.contains("any")
            })], as: User.self)
        )
        
        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope.value.contains("one")
            }) || AuthBasePredicate(closure: { carrier in
                carrier.scope.value.contains("any")
            })], as: User.self)
        )
        
        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthBasePredicate(closure: { carrier in
                carrier.scope.hasAuth(required: "one")
            })], as: User.self)
        )
    }
    
    func testFieldPredicate() {
        let u = User.dummy(scope: ["one", "two"])
        
        let request = Request(application: app, on: app.eventLoopGroup.next())
        request.auth.login(u)
        
        XCTAssertTrue(
            try AuthHandler(request: request).satisfied(with: [AuthFieldPredicate(\User.scope, "one")], as: User.self)
        )
    }
}
