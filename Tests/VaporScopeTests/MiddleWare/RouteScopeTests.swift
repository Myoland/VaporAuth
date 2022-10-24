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

class A_Model {
}

extension A_Model: ResoureIndicator {
    static var resource: String {
        "\(Self.self)"
    }
}

extension A_Model {
    enum Scopes {
        static let bar = Scope(resource: A_Model.resource, action: "bar")
    }
}

extension Scope {
    enum A_Model_Action: String, ScopeAllocator {
        typealias Resource = A_Model
        
        case foo = "foo"
    }
}

final class ScopedRouterBundlerTests: XCTestCase {
    
    
    func testBuilderDemo() async throws {
        let r = Routes()
        r.group("api") {
            $0.on(.GET, "a", use: fake).scope(with: ["a_scope"], by: User.self)
            $0.on(.GET, "b", use: fake).scope(with: "a_scope", by: User.self)
            
            $0.on(.GET, "c", use: fake).scope(with: .A_Model_Action.foo.scope, by: User.self)
            $0.on(.GET, "d", use: fake).scope(with: A_Model.Scopes.bar, by: User.self)
            
            $0.on(.GET, "e", use: fake).scope(with: [A_Model.Scopes.bar, .A_Model_Action.foo.scope], by: User.self)
            
            $0.on(.GET, "f", use: fake).scope(with: .init(resource: A_Model.resource, action: "try"), by: User.self)
        }
        print(r)
    }
    
    func fake(req: Request) async throws -> HTTPStatus {
        return .ok
    }
}
