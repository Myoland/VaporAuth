# VaporScope

VaporScope is a library to use Scope in Vapor.

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

You should know how we get payload and decode it.

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

We usually create a `Middleware` helping login a user.

It is how:

```Swift
route.group(User.authenticator()) {
    $0.get(use: handler)
}
```

### Scope

In this part we will show how to use `VaporScope` for Scope-based authentication.

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
