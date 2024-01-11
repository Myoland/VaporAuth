//
//  File.swift
//  
//
//  Created by AFuture D on 2022/9/13.
//

@testable import VaporAuth
import XCTest

final class ScopeWrapperTests: XCTestCase {
    
    func testWrapperCreate() async throws {
        let a = ScopeWrapper(raw: "recommend.release:read")
        XCTAssertNotNil(a.scope)
        XCTAssertEqual(a.raw, a.scope?.rawValue)
        
        let b = ScopeWrapper(raw: "recommend.release:*")
        XCTAssertNotNil(b.scope)
        XCTAssertEqual(b.raw, b.scope?.rawValue)
        
        let c = ScopeWrapper(raw: "recommend.release")
        XCTAssertNil(c.scope)
    }
    
    func testWrapperEqual() async throws {
        let a = ScopeWrapper(raw: "recommend.release:read")
        let b = ScopeWrapper(raw: "recommend.release:read")
        XCTAssertEqual(a, b)
        
        let c = ScopeWrapper(raw: "recommend-common")
        let d = ScopeWrapper(raw: "recommend-common")
        XCTAssertEqual(c, d)
    }
    
    func testWrapperNotEqual() async throws {
        let a = ScopeWrapper(raw: "recommend.release:read")
        let b = ScopeWrapper(raw: "recommend.release:*")
        XCTAssertNotEqual(a, b)
        XCTAssert(a <= b)
        
        let c = ScopeWrapper(raw: "recommend.release")
        XCTAssertNotEqual(a, c)
        XCTAssertFalse(a <= c)
        XCTAssertFalse(a >= c)
    }
}

