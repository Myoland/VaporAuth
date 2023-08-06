
import Foundation



public func && <T: AuthCarrier> (
    lhs: AuthBasePredicate<T>,
    rhs: AuthBasePredicate<T>
) -> any AuthPredicate<T> {
    lhs.and(other: rhs)
}

public func && <T: AuthCarrier> (
    lhs: AuthBasePredicate<T>,
    rhs: any AuthPredicate<T>
) -> any AuthPredicate<T> {
    lhs.and(other: rhs)
}

public func && <T: AuthCarrier> (
    lhs: any AuthPredicate<T>,
    rhs: AuthBasePredicate<T>
) -> any AuthPredicate<T> {
    lhs.and(other: rhs)
}

public func || <T: AuthCarrier> (
    lhs: AuthBasePredicate<T>,
    rhs: AuthBasePredicate<T>
) -> any AuthPredicate<T> {
    lhs.or(other: rhs)
}

public func || <T: AuthCarrier> (
    lhs: AuthBasePredicate<T>,
    rhs: any AuthPredicate<T>
) -> any AuthPredicate<T> {
    lhs.or(other: rhs)
}

public func || <T: AuthCarrier> (
    lhs: any AuthPredicate<T>,
    rhs: AuthBasePredicate<T>
) -> any AuthPredicate<T> {
    lhs.or(other: rhs)
}


public struct AuthBasePredicate<Carrier>: AuthPredicate where Carrier: AuthCarrier {

    private let closure: (Carrier) -> Bool

    public init(closure: @escaping (Carrier) -> Bool) {
        self.closure = closure
    }


    public func hasAuth(carrier: Carrier) -> Bool {
        return self.closure(carrier)
    }
}


extension AuthPredicate {
    public func and(other: any AuthPredicate<T>) -> any AuthPredicate<T> {
        return AuthBasePredicate { carrier in
            return self.hasAuth(carrier: carrier) && other.hasAuth(carrier: carrier)
        }
    }
    
    public func or(other: any AuthPredicate<T>) -> any AuthPredicate<T> {
        return AuthBasePredicate { carrier in
            return self.hasAuth(carrier: carrier) || other.hasAuth(carrier: carrier)
        }
    }
    
    public func not() -> any AuthPredicate<T> {
        return AuthBasePredicate { carrier in
            return !self.hasAuth(carrier: carrier)
        }
    }
}

