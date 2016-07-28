//
//  MPValue.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

public enum MPValue {

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

// MARK: - Shortcut getters

public extension MPValue {

    func arrayValue() -> [MPValue]? {
        guard case let .array(val) = self else { return nil }
        return val
    }

    func binaryValue() -> Binary? {
        guard case let .binary(val) = self else { return nil }
        return val
    }

    func boolValue() -> Bool? {
        guard case let .bool(val) = self else { return nil }
        return val
    }

    func dictionaryValue() -> [MPValue: MPValue]? {
        guard case let .dictionary(val) = self else { return nil }
        return val
    }

    func doubleValue() -> Double? {
        if case let .double(val) = self { return val }
        if case let .float(val) = self { return Double(val) }
        if let int64 = int64Value() { return Double(int64) }
        if let uint64 = uint64Value() { return Double(uint64) }
        return nil
    }

    func extensionValue() -> Extension? {
        guard case let .extension(val) = self else { return nil }
        return val
    }

    func floatValue() -> Float? {
        if case let .float(val) = self { return val }
        if case let .double(val) = self { return Float(val) }
        if let int64 = int64Value() { return Float(int64) }
        if let uint64 = uint64Value() { return Float(uint64) }
        return nil
    }

    func int64Value() -> Int64? {
        if case let .int64(val) = self { return val }
        if case let .uint64(val) = self { return val <= UInt64(Int64.max) ? Int64(val) : nil }
        if case let .double(val) = self { return Int64(val) }
        if case let .float(val) = self { return Int64(val) }
        return nil
    }

    func intValue() -> Int? {
        #if arch(arm) || arch(i386)
            return int64Value().flatMap { $0 >= Int64(Int.min) && $0 <= Int64(Int.max) ? Int($0): nil }
        #else
            return int64Value().flatMap(Int.init)
        #endif
    }

    func isNil() -> Bool {
        if case .nil = self { return true }
        return false
    }

    func stringValue() -> String? {
        guard case let .string(val) = self else { return nil }
        return val
    }

    func uint64Value() -> UInt64? {
        if case let .uint64(val) = self { return val }
        if case let .int64(val) = self { return val < 0 ? nil : UInt64(val) }
        if case let .double(val) = self { return val < 0 ? nil : UInt64(val) }
        if case let .float(val) = self { return val < 0 ? nil : UInt64(val) }
        return nil
    }

    func uintValue() -> UInt? {
        #if arch(arm) || arch(i386)
            return uint64Value().flatMap { $0 >= UInt64(UInt.min) && $0 <= UInt64(UInt.max) ? UInt($0) : nil }
        #else
            return uint64Value().flatMap(UInt.init)
        #endif
    }

}

// MARK: - Hashable

extension MPValue: Hashable {

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

}

public func ==(lhs: MPValue, rhs: MPValue) -> Bool {
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

// MARK: - LiteralConvertibles

extension MPValue: ArrayLiteralConvertible {

    public init(arrayLiteral elements: MPValue...) {
        self = .array(elements)
    }

}

extension MPValue: BooleanLiteralConvertible {

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

}

extension MPValue: DictionaryLiteralConvertible {

    public init(dictionaryLiteral elements: (MPValue, MPValue)...) {
        var dic = [MPValue: MPValue]()
        for (k, v) in elements {
            dic[k] = v
        }

        self = .dictionary(dic)
    }

}

extension MPValue: FloatLiteralConvertible {

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

extension MPValue: IntegerLiteralConvertible {

    public init(integerLiteral value: Int) {
        self = .int64(numericCast(value))
    }

}

extension MPValue: NilLiteralConvertible {

    public init(nilLiteral: ()) {
        self = .nil
    }

}

extension MPValue: ExtendedGraphemeClusterLiteralConvertible {

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
}


extension MPValue: UnicodeScalarLiteralConvertible {

    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }

}

extension MPValue: StringLiteralConvertible {

    public init(stringLiteral value: String) {
        self = .string(value)
    }

}
