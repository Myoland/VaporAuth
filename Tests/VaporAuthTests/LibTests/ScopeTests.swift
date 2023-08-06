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
        let a = Scope(rawValue: "recommend.release:read")!
        let b = Scope(rawValue: "recommend.release:read")!
        XCTAssert(a == b)
    }
    
    func testScopeSmaller() async throws {
        let a = Scope(rawValue: "recommend.release.week:read")!
        let b = Scope(rawValue: "recommend.release:read")!
        XCTAssert(a <= b)
        
        let c = Scope(rawValue: "recommend:read")!
        XCTAssert(b <= c)
        XCTAssert(a <= c)
        
        let d = Scope(rawValue: "recommend:*")!
        XCTAssert(a <= d)
        XCTAssert(b <= d)
        XCTAssert(c <= d)
        
        let e = Scope(rawValue: "recommend.release:write")!
        XCTAssertFalse(a <= e)
        XCTAssertFalse(b <= e)
        XCTAssertFalse(c <= e)
        
        let f = Scope(rawValue: "recommend.release:*")!
        XCTAssert(a <= f)
        XCTAssert(b <= f)
        XCTAssertFalse(c <= f)
    }
    
    func testScopeGreater() async throws {
        let a = Scope(rawValue: "recommend.release.week:read")!
        let b = Scope(rawValue: "recommend.release:read")!
        XCTAssert(b >= a)
        
        let c = Scope(rawValue: "recommend:read")!
        XCTAssert(c >= b)
        XCTAssert(c >= a)
        
        let d = Scope(rawValue: "recommend:*")!
        XCTAssert(d >= a)
        XCTAssert(d >= b)
        XCTAssert(d >= c)
        
        let e = Scope(rawValue: "recommend.release:write")!
        XCTAssertFalse(e >= a)
        XCTAssertFalse(e >= b)
        XCTAssertFalse(e >= c)
        
        let f = Scope(rawValue: "recommend.release:*")!
        XCTAssert(f >= a)
        XCTAssert(f >= b)
        XCTAssertFalse(f >= c)
    }
    
    func testScopeArray() async throws {
        let requiredScopes = [
            Scope(rawValue: "recommend.release.week:read")!,
            Scope(rawValue: "recommend.release:read")!
        ]
        
        let userScopes = [
            Scope(rawValue: "recommend.release:*")!,
            Scope(rawValue: "recommend.release:write")!
        ]
        
        XCTAssert([] <= userScopes)
        XCTAssertFalse(requiredScopes <= [])
        XCTAssert(requiredScopes <= userScopes)
        
        XCTAssertFalse(requiredScopes <= [
            Scope(rawValue: "recommend.release:write")!
        ])
        
    }
}
