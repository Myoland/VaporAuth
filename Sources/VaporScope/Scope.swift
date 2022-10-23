//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/23.
//

import Foundation
import Vapor
import AsyncHTTPClient

/// A Struct for Scope
///
/// A scope contains two part:
///   1. resource
///   2. action
///
/// Resource and Action are septrated by `SEPARATER`.
///
/// If action is `ACTION_SET_MARK`, than it mean the whole set of actions upon the Resource.
///
/// Joined by `RESOURCE_LINKER`, a Resource may contains mutiple sub items,
/// which also show the relation between them.
public struct Scope {
    public static let SEPARATER: Character = ":"
    public static let RESOURCE_LINKER: Character = "."
    public static let ACTION_SET_MARK: String = "*"
    
    let resource: String
    let action: String
    
    public init(resource:String, action: String) {
        self.resource = resource
        self.action = action
    }
    
    init?(raw: String) {
        let p = raw.split(separator: Scope.SEPARATER)
        if p.count != 2 {
            return nil
        }
        let r = p[0]
        let a = p[1]
        self.init(resource:String(r), action:String(a))
    }
    
    /// The parent Scope
    ///
    /// For example:
    ///   - the parent of "AAA.BBB:XXX" would be "AAA:XXX".
    ///   - the parent of "AAA:XXX" would be nil
    var parent: Scope? {
        guard let ps = self.resource.lastIndex(of: Scope.RESOURCE_LINKER) else {
            return nil
        }
        let p = self.resource.index(before: ps)
        let r = self.resource[...p]
        return .init(resource: String(r), action: self.action)
    }
}

extension Scope {
    public var raw: String {
        return "\(resource)\(Scope.SEPARATER)\(action)"
    }
}

extension Scope: CustomStringConvertible {
    public var description: String {
        return "Scope<\(self.resource):\(self.action)>"
    }
}

/// for-in loop support
extension Scope:Sequence, IteratorProtocol {
    public typealias Element = Scope
    
    public func makeIterator() -> AnyIterator<Scope> {
        var cur: Scope? = self
        let iterator: AnyIterator<Scope> = AnyIterator {
            defer { cur = cur?.parent }
            return cur
        }
        return iterator
    }
    
    public func next() -> Scope? {
        self.parent
    }
}

extension Scope: Equatable {
    public static func == (lhs: Scope, rhs: Scope) -> Bool {
        return lhs.resource == rhs.resource
        && lhs.action == rhs.action
    }
}


/// The basic Scope Operator
///
/// As a Scope = Resource + Action, so we may define
/// the binary relation based on these two things.
///
/// 1. every action is dependent to each other.
/// 2. `ACTION_SET_MARK` means the whole action set, which means ``
/// contains all actions.
/// 3. compare could be done only when two scope has
/// the same action or one is `ACTION_SET_MARK`.
/// 4. if one resource contains another, it mean this
/// resource is the prefix of another。
extension Scope {
    public static func <= (lhs: Scope, rhs: Scope) -> Bool {
        var r = rhs
        if rhs.action == Scope.ACTION_SET_MARK {
            r = Scope(resource: rhs.resource, action: lhs.action)
        }
        for parent in lhs {
            if parent == r {
                return true
            }
        }
        return false
    }
    
    public static func >= (lhs: Scope, rhs: Scope) -> Bool {
        var l = lhs
        if lhs.action == Scope.ACTION_SET_MARK {
            l = Scope(resource: lhs.resource, action: rhs.action)
        }
        for parent in rhs {
            if parent == l {
                return true
            }
        }
        return false
    }
}

extension Array where Element == Scope {
    static func <= (lhs: [Scope], rhs: [Scope]) -> Bool {
        for requiredScope in lhs {
            let hasPermission = rhs.reduce(false) { result, userScope in
                return result || (requiredScope <= userScope)
            }
            if hasPermission == false {
                return false
            }
        }
        return true
    }
    
    public func contains(_ element: Element) -> Bool {
        return self <= [element]
    }
}
