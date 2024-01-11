//
//  File.swift
//  
//
//  Created by AFuture on 2023/7/31.
//

import Foundation
import XCTest
import VaporAuth

final class ScopeClaimTests: XCTestCase {
    
    func testInit() async throws {
        let a = ScopeClaim(value: ["a", "b"])
        let b = ScopeClaim(stringLiteral: "a b")
        let c = ScopeClaim(arrayLiteral: "a", "b")
        let d: ScopeClaim = "a b"
        let e: ScopeClaim = ["a", "b"]
        
        assert(a == b)
        assert(b == c)
        assert(c == d)
        assert(d == e)
    }
    
    func testEncode() async throws {
        let a = ScopeClaim(value: ["a", "b"])
        let encoded = try JSONEncoder().encode(a)
        let decoded = try JSONDecoder().decode(ScopeClaim.self, from: encoded)
        assert(decoded == a)
    }
    
    func testEqual() async throws {
        let a = ScopeClaim(value: ["a", "b"])
        let b = ScopeClaim(value: ["a", "b"])
        assert(a == b)
        assert(b == a)
        
        let c = ScopeClaim(value: ["b", "a"])
        assert(a == c)
        
        let d = ScopeClaim(value: ["a"])
        let e = ScopeClaim(value: ["a", "b", "c"])
        assert(a != d)
        assert(a != e)
    }
    
    func testCompare() async throws {
        let a = ScopeClaim(value: ["a"])
        let b = ScopeClaim(value: ["a", "b"])
        let c = ScopeClaim(value: ["a", "b", "c"])
        
        assert(a < b)
        assert(b < c)
        assert(a < c)
        
        assert(a <= b)
        assert(b <= c)
        assert(a <= c)
        
        assert(b > a)
        assert(c > b)
        assert(c > a)
        
        assert(b >= a)
        assert(c >= b)
        assert(c >= a)
    }
    
    func testHasAuth() async throws {
        let carried = ScopeClaim(value: ["a", "b"])
        XCTAssertTrue(carried.hasAuth(required: "a"))
        XCTAssertTrue(carried.hasAuth(required: "a b"))
    }
}

