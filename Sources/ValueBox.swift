//
//  ValueBox.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

public enum ValueBox {

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

// MARK: - Shortcut getters

public extension ValueBox {

    var array: [ValueBox]? {
        guard case let .array(val) = self else { return nil }
        return val
    }

    var binary: Binary? {
        guard case let .binary(val) = self else { return nil }
        return val
    }

    var bool: Bool? {
        guard case let .bool(val) = self else { return nil }
        return val
    }

    var dictionary: [ValueBox: ValueBox]? {
        guard case let .dictionary(val) = self else { return nil }
        return val
    }

    var double: Double? {
        if case let .double(val) = self { return val }
        if case let .float(val) = self { return Double(val) }
        if let int64 = int64 { return Double(int64) }
        if let uint64 = uint64 { return Double(uint64) }
        return nil
    }

    var `extension`: Extension? {
        guard case let .extension(val) = self else { return nil }
        return val
    }

    var float: Float? {
        if case let .float(val) = self { return val }
        if case let .double(val) = self { return Float(val) }
        if let int64 = int64 { return Float(int64) }
        if let uint64 = uint64 { return Float(uint64) }
        return nil
    }

    var int64: Int64? {
        if case let .int64(val) = self { return val }
        if case let .uint64(val) = self { return val <= UInt64(Int64.max) ? Int64(val) : nil }
        if case let .double(val) = self { return Int64(val) }
        if case let .float(val) = self { return Int64(val) }
        return nil
    }

    var int: Int? {
        #if arch(arm) || arch(i386)
            return int64.flatMap { $0 >= Int64(Int.min) && $0 <= Int64(Int.max) ? Int($0): nil }
        #else
            return int64.flatMap(Int.init)
        #endif
    }

    var isNil: Bool {
        if case .nil = self { return true }
        return false
    }

    var string: String? {
        guard case let .string(val) = self else { return nil }
        return val
    }

    var uint64: UInt64? {
        if case let .uint64(val) = self { return val }
        if case let .int64(val) = self { return val < 0 ? nil : UInt64(val) }
        if case let .double(val) = self { return val < 0 ? nil : UInt64(val) }
        if case let .float(val) = self { return val < 0 ? nil : UInt64(val) }
        return nil
    }

    var uint: UInt? {
        #if arch(arm) || arch(i386)
            return uint64.flatMap { $0 >= UInt64(UInt.min) && $0 <= UInt64(UInt.max) ? UInt($0) : nil }
        #else
            return uint64.flatMap(UInt.init)
        #endif
    }

    func box(for keyPath: String) -> ValueBox? {
        let keys = keyPath.components(separatedBy: ".")
        var box: ValueBox? = self
        for key in keys {
            box = box?.dictionary?[.string(key)]
        }

        return box
    }

    func value<T : UnpackableStdType>(for keyPath: String) -> T? {
        return box(for: keyPath)?.value()
    }
    
}

// MARK: - subscript support

public extension ValueBox {
    subscript (keyPath: String) -> ValueBox? {
        return box(for: keyPath)
    }

    subscript (array keyPath: String) -> [ValueBox]? {
        return self[keyPath]?.array
    }

    subscript (binary keyPath: String) -> Binary? {
        return self[keyPath]?.binary
    }

    subscript (bool keyPath: String) -> Bool? {
        return self[keyPath]?.bool
    }

    subscript (dictionary keyPath: String) -> [ValueBox: ValueBox]? {
        return self[keyPath]?.dictionary
    }

    subscript (double keyPath: String) -> Double? {
        return self[keyPath]?.double
    }

    subscript (extension keyPath: String) -> Extension? {
        return self[keyPath]?.extension
    }

    subscript (float keyPath: String) -> Float? {
        return self[keyPath]?.float
    }

    subscript (int64 keyPath: String) -> Int64? {
        return self[keyPath]?.int64
    }

    subscript (string keyPath: String) -> String? {
        return self[keyPath]?.string
    }

    subscript (uint64 keyPath: String) -> UInt64? {
        return self[keyPath]?.uint64
    }
}

// MARK: - Hashable

extension ValueBox: Hashable {

    public var hashValue: Int {
        switch self {
        case .array(let val):
            return val.count
        case .binary(let val):
            return val.hashValue
        case .bool(let val):
            return val.hashValue
        case .dictionary(let val):
            return val.count
        case .double(let val):
            return val.hashValue
        case .extension(let val):
            return val.hashValue
        case .float(let val):
            return val.hashValue
        case .int64(let val):
            return val.hashValue
        case .nil:
            return 0
        case .string(let val):
            return val.hashValue
        case .uint64(let val):
            return val.hashValue
        }
    }

    public static func ==(lhs: ValueBox, rhs: ValueBox) -> Bool {
        switch (lhs, rhs) {
        case let (.array(lv), .array(rv)):
            return lv == rv
        case let (.binary(lv), .binary(rv)):
            return lv == rv
        case let (.bool(lv), .bool(rv)):
            return lv == rv
        case let (.dictionary(lv), .dictionary(rv)):
            return lv == rv
        case let (.double(lv), .double(rv)):
            return lv == rv
        case let (.extension(lv), .extension(rv)):
            return lv == rv
        case let (.float(lv), .float(rv)):
            return lv == rv
        case let (.int64(lv), .int64(rv)):
            return lv == rv
        case (.nil, .nil):
            return true
        case let (.string(lv), .string(rv)):
            return lv == rv
        case let (.uint64(lv), .uint64(rv)):
            return lv == rv
        default:
            return false
        }
    }

}

// MARK: - LiteralConvertibles

extension ValueBox: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: ValueBox...) {
        self = .array(elements)
    }

}

extension ValueBox: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

}

extension ValueBox: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (ValueBox, ValueBox)...) {
        var dic = [ValueBox: ValueBox]()
        for (k, v) in elements {
            dic[k] = v
        }

        self = .dictionary(dic)
    }

}

extension ValueBox: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        let int64 = Int64(value)
        let flt = Float(value)
        if Double(int64) == value {
            self = .int64(int64)
        } else if Double(flt) == value {
            self = .float(flt)
        } else {
            self = .double(value)
        }
    }

}

extension ValueBox: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .int64(numericCast(value))
    }

}

extension ValueBox: ExpressibleByNilLiteral {

    public init(nilLiteral: ()) {
        self = .nil
    }

}

extension ValueBox: ExpressibleByExtendedGraphemeClusterLiteral {

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }

}


extension ValueBox: ExpressibleByUnicodeScalarLiteral {

    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }

}

extension ValueBox: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }

}
