//
//  File.swift
//  
//
//  Created by 尼诺 on 2023/7/28.
//

import Foundation
import JWTKit

public struct ScopeClaim: JWTClaim, Equatable {
    
    /// See [Section 3.3]((https://www.rfc-editor.org/rfc/rfc6749#section-3.3).) of [RFC6749](https://www.rfc-editor.org/info/rfc6749)
    ///
    /// > The value of the scope parameter is expressed as a list of space-delimited, case-sensitive strings.
    public var value: [String]

    public init(value: [String]) {
        self.value = value
    }
    
    public static func == (lhs: ScopeClaim, rhs: ScopeClaim) -> Bool {
        return Set(rhs.value) == Set(lhs.value)
    }

}


extension ScopeClaim: ExpressibleByStringLiteral {
    private static let SEPTRATOR = " "

    public init(stringLiteral value: String) {
        let value = value.components(separatedBy: ScopeClaim.SEPTRATOR)
        self.init(value: value)
    }
}

extension ScopeClaim: ExpressibleByArrayLiteral {
    public init(arrayLiteral value: String...) {
        self.init(value: value)
    }
}


extension ScopeClaim: Comparable {
    public static func < (lhs: ScopeClaim, rhs: ScopeClaim) -> Bool {
        return Set(lhs.value).isStrictSubset(of: Set(rhs.value))
    }
}

extension ScopeClaim: Guardable {
    public func hasAuth(required: ScopeClaim) -> Bool {
        required <= self
    }
}
