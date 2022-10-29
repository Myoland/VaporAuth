# VaporScope

VaporScope is a library to use Scope in Vapor.

- [Installation](#installation)
    - [SPM](#swift-package-manager)
- [Usage](#usage)
    - [Requirement](#requirement)
    - [Define a payload](#define-a-payload)
    - [Tips](#tips)
        - [Encode and Decode](#encode-and-decode)
        - [Login](#login)
        - [Authenticator](#authenticator)
    - [Scope](#scope)
        - [ScopeHandler](#scopehandler)
        - [GuardMiddleware](#guardmiddleware)
    - [Routes](#routes)
        - [Easiest](#easiest)
        - [Nicer](#nicer)
        - [Ultimate](#ultimate)


## Installation

### Swift Package Manager

```Swift
dependencies: [
    .package(url: "https://github.com/Myoland/VaporScope.git", from: "0.1.0"),
]
```

## Usage

### Requirement

This library is built on the `ScopeCarrier` protocol which conforms to `JWTPayload`.

So, it is important that your project is using JWT for authentication.

### Define a payload


To start, create a payload and let it conform to the `ScopeCarrier`.

For Example:

```Swift
public struct User: ScopeCarrier {
    enum CodingKeys: String, CodingKey {...}
    
    public var subject: SubjectClaim
    public var expiration: ExpirationClaim
    public var scopes: [String]
    
    public func verify(using signer: JWTSigner) throws {...}
    
    public init(...) {...}
}
```

For more detail, go to [ScopeCarrier+Testable.swift](./Tests/VaporScopeTests/Utils/ScopeCarrier%2BTestable.swift).

### Tips

#### Encode and Decode

Based on `JWTPayload`, it's for sure that you can encode or decode your payload for further transmission.

You should know how we get the payload and decode it.

```Swift
// Encode
let user = User(...)
let encode = try app.jwt.signers.sign(u)

// Decode
let payload = try request.jwt.verify(as:User.self)
```

#### Login

```Swift
let user = User(...)
try await User.authenticator().authenticate(jwt: user, for: request)

// OR

let user = User(...)
try await user.authenticate(request: request)
```

#### Authenticator

We usually create a `Middleware` to help login a user.

It is how:

```Swift
route.group(User.authenticator()) {
    $0.get(use: handler)
}
```

### Scope

In this part, we will show how to use `VaporScope` for Scope-based authentication.

In [ScopeHandler.swift](./Sources/VaporScope/ScopeHandler.swift), we define the basic logic for assearting scopes. See `ScopeHandler.assertScopes(_:carried:)` for more detail.

As you can see, when we try to assert the scopes, we define that every required scope should be contained by carried scopes. `Contained` means a required scope should be satisfied by one of the carried scopes.   

#### ScopeHandler

Every request has an independent authentication, so we need a method to check every request.

Use `ScopeHandler` to help you check every request.

```Swift
try ScopeHandler(request: request).satisfied(with: ["all.part:read"], as: User.self)

// OR

try request.oauth.satisfied(with: self.scopes, as: User.self)
```

#### GuardMiddleware

We also provide a better way to use ScopeHandler.

```Swift
route.routes.grouped([
    User.guardMiddleware(with: ["one", "two"])
]).get("action", use: handler)
```

### Routes

Based on `GuardMiddleware`, we can easily use it when building routes.

After some experiments, we found it is better that scopes directly attach to the route endpoint. Creating some language sugar will cause RouteBuilder to be messy.

There are some ways to do this.

All examples can be found in [RouteScopeTests](./Tests/VaporScopeTests/MiddleWare/RouteScopeTests.swift)

#### Easiest

Using String! And you can use `enum` to make it nice.

``` Swift

extension A_Model {
    enum Scopes: String {
        case bar = "bar"
        case foo = "foo"
    }
}

struct A_Controller: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use:fake).scope(with: A_Model.Scopes.bar.rawValue, by: User.self)
    }
}
```

#### Nicer

Using `Scope`! The `rawValue` is to much noisy, we want it to disappear!

``` Swift
extension A_Model {
    enum Scopes {
        static let foo = "A_Model:foo"
        static let bar = Scope(resource: "A_Model", action: "bar")
        static let baz = Scope(resource: "A_Model", action: "baz")
    }
}

struct A_Controller: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use:fake).scope(with: A_Model.Scopes.foo, by: User.self)
        routes.get(use:fake).scope(with: A_Model.Scopes.bar, by: User.self)
        routes.get(use:fake).scope(with: A_Model.Scopes.baz, by: User.self)
    }
}
```

#### Ultimate

The method above case is still not elegant, because the enumeration cases are static and not raw values!

``` Swift
extension A_Model: ResoureIndicator {
    public static var resource: String {
        "A_Model"
    }
}

extension Scope {
    enum A_Model_Action: String, ScopeAllocator {
        typealias Resource = A_Model
        
        case foo = "foo"
        case bar = "bar"
    }
}

struct A_Controller: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use:fake).scope(with: .A_Model_Action.foo.scope, by: User.self)
        routes.get(use:fake).scope(with: .A_Model_Action.bar.scope, by: User.self)
    }
}
```

> We find that we can let `ScopeWrapper` conform to `ExpressibleByStringLiteral` and make `enum` much more simple. But, we not implement it.
