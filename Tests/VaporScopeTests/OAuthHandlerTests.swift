//
//  File.swift
//
//
//  Created by AFuture D. on 2022/7/19.
//

@testable import VaporScope
import Vapor
import XCTVapor

final class OAuthHandlerTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        app = Application(.testing)
        try app.jwt.signers.use(jwk: JWTHelper.jwkPrivate, isDefault: true)
        try app.jwt.signers.use(jwk: JWTHelper.jwk)
    }
    
    override func tearDown() async throws {
        app.shutdown()
    }
    
    func testMissPayload() async throws {
        let request = Request(application: app, on: app.eventLoopGroup.next())
        
        XCTAssertThrowsError(
            try ScopeHandler(request: request).getPayLoad(as: User.self)
        ) { error in
            XCTAssertEqual((error as? AbortError)?.status, .unauthorized)
        }
        
        
        XCTAssertThrowsError(
            try ScopeHandler(request: request).satisfied(with: [], as: User.self)
        ) { error in
            XCTAssertEqual((error as? AbortError)?.status, .unauthorized)
        }
    }
    
    func testGetPayload() async throws {
        // scope
        let u = User.dummy(scope: ["all.part:read"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)
        
        XCTAssertEqual(
            try ScopeHandler(request: request).getPayLoad(as: User.self).subject.value,
            u.subject.value
        )
    }
   
    func testAssertScopes() async throws {
        XCTAssertTrue(
            ScopeHandler(request: nil).assertScopes(["all"], carried: ["all"])
        )
        
        XCTAssertTrue(
            ScopeHandler(request: nil).assertScopes(["all"], carried: ["all", "one"])
        )
        
        XCTAssertFalse(
            ScopeHandler(request: nil).assertScopes(["all", "one"], carried: ["all"])
        )
        
        XCTAssertTrue(
            ScopeHandler(request: nil).assertScopes(["all.part:read"], carried: ["all.part:*"])
        )
        
        XCTAssertFalse(
            ScopeHandler(request: nil).assertScopes(["all.part:*"], carried: ["all.part:read"])
        )
        
        XCTAssertFalse(
            ScopeHandler(request: nil).assertScopes(["all.part:write"], carried: ["all.part:read"])
        )
    }
    
    func test1v1_Scope() async throws {

        // scope
        let u = User.dummy(scope: ["all.part:read"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.part:write"], as: User.self)
        )

        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.part.sub:read"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.part:*"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all:*"], as: User.self)
        )
    }

    func test1v1_String() async throws {

        // string literal
        let u = User.dummy(scope: ["all"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["error"], as: User.self)
        )
    }

    func testUserSingle_RequiredHasSub() async throws {

        // scope
        let u = User.dummy(scope: ["all.part:read"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read", "all.part.sub:read"], as: User.self)
        )
    }

    func testUserSingle_RequiredMiss() async throws {

        // scope
        let u = User.dummy(scope: ["all.part:read"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read", "all.part:write"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read", "all.part:*"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read", "all:read"], as: User.self)
        )
        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read", "all:*"], as: User.self)
        )
    }

    func testUserSingleAll_RequiredMuti() async throws {

        // scope
        let u = User.dummy(scope: ["all.part:*"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.part:read", "all.part:write"], as: User.self)
        )

        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all:read", "all:write", "all:*"], as: User.self)
        )
    }

    func testUserMuti_MutiRes_Required() async throws {

        // scope
        let u = User.dummy(scope: ["all.partA:read", "all.partB:*"])

        let request = Request(application: app, on: app.eventLoopGroup.next())
        try await User.authenticator().authenticate(jwt: u, for: request)

        // single required scope
        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.partA:read"], as: User.self)
        )

        // single required scope with sub action
        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.partB:read"], as: User.self)
        )

        // muti required scope
        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.partA:read", "all.partB:write"], as: User.self)
        )

        // muti sub required scope
        XCTAssertTrue(
            try ScopeHandler(request: request).satisfied(with: ["all.partA.sub:read", "all.partB.sub:*"], as: User.self)
        )

        // miss one required scope
        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all.partA:*"], as: User.self)
        )

        // miss one required scope
        XCTAssertFalse(
            try ScopeHandler(request: request).satisfied(with: ["all:*", "all.partB:write"], as: User.self)
        )
    }
}
