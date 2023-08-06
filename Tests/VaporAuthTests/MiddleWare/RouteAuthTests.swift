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
            $0.on(.GET, "a", use: fake)
            $0.grouped(\User.subject, "FAKE_ID")
                .grouped(\User.scope, ["b_scope", "c_scope"])
                .on(.GET, "a", use: fake)
            
            $0.grouped(User.authenticator()).grouped {
                .init(\User.subject, "FAKE_ID")
                && .init(\User.scope, ["b_scope", "c_scope"])
                || .init(closure: {
                    $0.expiration.value > .now
                })
            }.on(.GET, "a", use: fake)            

        }
        print(r)
    }

    func fake(req: Request) async throws -> HTTPStatus {
        return .ok
    }
}
