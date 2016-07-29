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

If you want to pack data with mixed types, use `MPValue`.

# Unpacking

```swift
struct Unpacker {
    static func unpack(bytes: Bytes) -> MPValue?
}
```

Unpack from data, conveniences for `Unpacker.unpack(bytes:)`:

```swift
extension Data {
    func unpack() -> MessagePack.MPValue?
    func unpack<T : UnpackableStdType>() -> T?
    func unpack<T : UnpackableStdType>() -> [T]?
    func unpack<K : HashableUnpackableStdType, V : UnpackableStdType>() -> [K : V]?
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

For other mixed types, you can alway use `MPValue` instead.

```swift
enum MPValue {
    case array([MPValue])
    case binary(Binary)
    case bool(Bool)
    case dictionary([MPValue: MPValue])
    case double(Double)
    case `extension`(Extension)
    case float(Float)
    case int64(Int64)
    case `nil`
    case string(String)
    case uint64(UInt64)
}
```
