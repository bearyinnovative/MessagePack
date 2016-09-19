# MessagePack for Swift

Swift implementation for [MessagePack](https://github.com/msgpack/msgpack/blob/master/spec.md).

# Packing

```swift
protocol Packable {
    func packToBytes() -> Bytes
    func pack() -> Data
}
```

Packable stdlib types:

- `Bool`, `Double`, `Int`, `UInt`, `Int64`, `UInt64`
- `Optional where Wrapped : Packable`
- `Array where Element: Packable` 
- `Dictionary where Key: Hashable, Key: Packable, Value: Packable`

Packable extended types:
- `Binary`
- `Extension`

If you want to pack data with mixed types, use `ValueBox`.

# Unpacking

```swift
struct Unpacker {
    static func unpack(bytes: Bytes) -> ValueBox?
}
```

Unpack from data, conveniences for `Unpacker.unpack(bytes:)`:

```swift
extension Data {
    func unpack() -> ValueBox?
}
```

Unpackable stdlib types contains:
- `Bool`
- `Double`
- `Float`
- `Int`
- `Int64`
- `String`
- `UInt`
- `UInt64`

For other mixed types, you can alway use `ValueBox` instead.

```swift
enum ValueBox {
    case array([ValueBox])
    case binary(Binary)
    case bool(Bool)
    case dictionary([ValueBox: ValueBox])
    case double(Double)
    case `extension`(Extension)
    case float(Float)
    case int64(Int64)
    case `nil`
    case string(String)
    case uint64(UInt64)
}
```
