//
//  File.swift
//
//
//  Created by AFuture D on 2022/9/13.
//


@testable import VaporScope
import Foundation
import XCTest
import JWT
import Vapor

final class ScopedRouterBundlerTests: XCTestCase {
   
    func testBuilderDemo() async throws {
        let r = Routes()
        r.grouped("try").scoped("resource", by: User.self) {
            $0.on(.GET, "no", use: fake)
        } .with(action: "read") {
            $0.on(.GET, "read", use: fake)
        } .with(action: "write") {
            $0.on(.GET, "write", use: fake)
        } .all {
            $0.on(.GET, "all", use: fake)
        }
        print(r)
    }
    
    func fake(req: Request) async throws -> HTTPStatus {
        return .ok
    }
}
