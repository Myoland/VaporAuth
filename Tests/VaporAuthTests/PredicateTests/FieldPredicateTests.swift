//
//  File.swift
//  
//
//  Created by 尼诺 on 2023/8/2.
//

import Foundation
import XCTest
import VaporAuth
import JWTKit

final class FieldPredicateTests: XCTestCase {
    
    func testBasic() async throws {
        struct Carrier: AuthCarrier {
            var sub: SubjectClaim = "sub"

            func verify(using algorithm: some JWTAlgorithm) async throws {}
        }
        
        let u = Carrier()
        
        let a = AuthFieldPredicate(\Carrier.sub, "sub")
        XCTAssertEqual(a.hasAuth(carrier: u),  true)
    }
    
    func testChain() async throws {
        struct Carrier: AuthCarrier {
            var sub: SubjectClaim = "sub"
            var iss: IssuerClaim = "issuer"

            func verify(using algorithm: some JWTAlgorithm) async throws {}
        }
        
        let u = Carrier()
        
        let a = AuthFieldPredicate(\Carrier.sub, "sub")
        
        let b = AuthFieldPredicate(\Carrier.iss, "fake")
        
        XCTAssertEqual(a.and(other: b).hasAuth(carrier: u),  false)
        XCTAssertEqual(a.or(other: b).hasAuth(carrier: u),  true)
        XCTAssertEqual(a.not().hasAuth(carrier: u),  false)
        
        let c = a && b
        let d = a || b
        XCTAssertEqual(c.hasAuth(carrier:u), false)
        XCTAssertEqual(d.hasAuth(carrier:u), true)
    }
}
