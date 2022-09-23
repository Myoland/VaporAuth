//
//  File.swift
//
//
//  Created by AFuture D. on 2022/7/19.
//

@testable import VaporScope
import XCTest

final class ScopeTests: XCTestCase {
    
    func testScopeEqual() async throws {
        let a = Scope(raw: "recommend.release:read")!
        let b = Scope(raw: "recommend.release:read")!
        XCTAssert(a == b)
    }
    
    func testScopeSmaller() async throws {
        let a = Scope(raw: "recommend.release.week:read")!
        let b = Scope(raw: "recommend.release:read")!
        XCTAssert(a <= b)
        
        let c = Scope(raw: "recommend:read")!
        XCTAssert(b <= c)
        XCTAssert(a <= c)
        
        let d = Scope(raw: "recommend:*")!
        XCTAssert(a <= d)
        XCTAssert(b <= d)
        XCTAssert(c <= d)
        
        let e = Scope(raw: "recommend.release:write")!
        XCTAssertFalse(a <= e)
        XCTAssertFalse(b <= e)
        XCTAssertFalse(c <= e)
        
        let f = Scope(raw: "recommend.release:*")!
        XCTAssert(a <= f)
        XCTAssert(b <= f)
        XCTAssertFalse(c <= f)
    }
    
    func testScopeGreater() async throws {
        let a = Scope(raw: "recommend.release.week:read")!
        let b = Scope(raw: "recommend.release:read")!
        XCTAssert(b >= a)
        
        let c = Scope(raw: "recommend:read")!
        XCTAssert(c >= b)
        XCTAssert(c >= a)
        
        let d = Scope(raw: "recommend:*")!
        XCTAssert(d >= a)
        XCTAssert(d >= b)
        XCTAssert(d >= c)
        
        let e = Scope(raw: "recommend.release:write")!
        XCTAssertFalse(e >= a)
        XCTAssertFalse(e >= b)
        XCTAssertFalse(e >= c)
        
        let f = Scope(raw: "recommend.release:*")!
        XCTAssert(f >= a)
        XCTAssert(f >= b)
        XCTAssertFalse(f >= c)
    }
    
    func testScopeArray() async throws {
        let requiredScopes = [
            Scope(raw: "recommend.release.week:read")!,
            Scope(raw: "recommend.release:read")!
        ]
        
        let userScopes = [
            Scope(raw: "recommend.release:*")!,
            Scope(raw: "recommend.release:write")!
        ]
        
        XCTAssert([] <= userScopes)
        XCTAssertFalse(requiredScopes <= [])
        XCTAssert(requiredScopes <= userScopes)
        
        XCTAssertFalse(requiredScopes <= [
            Scope(raw: "recommend.release:write")!
        ])
        
    }
}
