//
//  File.swift
//  
//
//  Created by 尼诺 on 2023/7/26.
//

import Foundation
import JWTKit
import JWT
import Vapor

 public protocol Guardable: JWTClaim & Equatable {
     func hasAuth(required: Self) -> Bool
 }

public extension Guardable where Self: Equatable {
     func hasAuth(required: Self) -> Bool {
         return self == required
     }
 }


public protocol AuthPredicate<T> {
    associatedtype T: AuthCarrier
    
    func hasAuth(carrier: T) -> Bool
    
    func and(other: any AuthPredicate<T>) -> any AuthPredicate<T>
    func or(other: any AuthPredicate<T>) -> any AuthPredicate<T>
    func not() -> any AuthPredicate<T>
}
