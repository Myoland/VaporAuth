# VaporScope

VaporAuth is a library for authorities assertion.

## Installation

### Swift Package Manager

```Swift
dependencies: [
    .package(url: "https://github.com/Myoland/VaporAuth.git", from: "1.0.0"),
]
```

## Quick Look

```Swift
import VaporAuth
public struct User: AuthCarrier {
    enum CodingKeys: String, CodingKey {...}
    
    public var subject: SubjectClaim
    public var scopes: ScopeClaim
    
    public func verify(using signer: JWTSigner) throws {...}
    
    public init(...) {...}
}

let app = try Application(.detect())
app.routes
    .grouped(User.authenticator())
    .grouped(\User.scope, "a_scope b_scope")
    .on(.GET, "a", use: handler)

app.routes
    .grouped(User.authenticator())
    .grouped(\User.subject, "sub")
    .grouped(\User.scope, ["a_scope", "b_scope"])
    .on(.GET, "a", use: handler)
```

## Usage

### Create a jwt claim

```swift
public struct ScopeClaim: JWTClaim, Equatable {

    public var value: [String]

    public init(value: [String]) {
        self.value = value
    }
    
    public static func == (lhs: ScopeClaim, rhs: ScopeClaim) -> Bool {
        return Set(rhs.value) == Set(lhs.value)
    }
}
```

### Conform to Guardable

```swift
extension ScopeClaim: Comparable {
    public static func < (lhs: ScopeClaim, rhs: ScopeClaim) -> Bool {...}
}

extension ScopeClaim: Guardable {
    public func hasAuth(required: ScopeClaim) -> Bool {
        required == self || required < self
    }
}
```

### Use it in authorities assertion

```swift
app.routes
    .grouped(User.authenticator())
    .grouped(\User.scope, ["a_scope", "b_scope"])
    .on(.GET, "a", use: handler)
```

## Detail


### Claim encode and decode

```swift
let scope = ScopeClaim(value: ["a", "b"])
let encoded = try JSONEncoder().encode(scope)
let decoded = try JSONDecoder().decode(ScopeClaim.self, from: encoded)
```

### Predicate

In order to compare value between required auth and cairried auth, we use the philosophy of predicate.

> A definition of logical conditions for constraining a search for a fetch or for in-memory filtering.

In general, to determine whether a user has the authority to access the handler, all we need is a boolean, a result. Thus, we do not care about required auth or any other things, We only care about the given auth and the result. That is what predicate do.

Notice, a predicate support basic logical operation, such as `&&`, `||`, `!`.

In VaporAuth, we provide `AuthPredicate` to help us determine whether a user has the authority.

There are two implementation of `AuthPredicate`, `AuthBasePredicate` and `AuthFieldPredicate`.

```swift
let a = AuthBasePredicate<Carrier> { user in
    user.sub == "some"
}
let b = AuthFieldPredicate(\Carrier.iss, "any")
let c = a && b

let _ = a.hasAuth(carrier: user) 
let _ = b.hasAuth(carrier: user)
let _ = c.hasAuth(carrier: user)

```

### Authenticate

Before checking the authority, we need to authenticate the user.

When you your info comfort to `JWTPayload`, it is easy to authenticate. 


```swift
 app.routes
    .grouped(User.authenticator())
    .on(.GET, "a", use: handler)
```
