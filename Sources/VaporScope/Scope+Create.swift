//
//  File.swift
//  
//
//  Created by AFuture D on 2022/10/24.
//

import Foundation
import Vapor

public protocol ResoureIndicator {
    static var resource: String { get }
}

public protocol ScopeAllocator {
    associatedtype Resource: ResoureIndicator
}

public extension ScopeAllocator where Self: RawRepresentable, Self.RawValue == String {
    var scope: Scope {
        return Scope(resource: Resource.resource, action: self.rawValue)
    }
}
