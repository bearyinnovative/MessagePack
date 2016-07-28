//
//  Spec.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import CommonDigest

public typealias Byte = UInt8

public typealias Bytes = Array<Byte>

// MARK: - Message Pack Binary
public struct Binary {

    public let bytes: Bytes

    public init(bytes: Bytes) {
        self.bytes = bytes
    }

    public init(bytes: ArraySlice<Byte>) {
        self.bytes = Array(bytes)
    }

}

extension Binary: Hashable {

    public var hashValue: Int {
        return hash(bytes: bytes)
    }

}

public func ==(lhs: Binary, rhs: Binary) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: - Message Pack Extension
public struct Extension {

    public let type: Int8

    public let binary: Binary

    public init(type: Int8, binary: Binary) {
        self.type = type
        self.binary = binary
    }

}

extension Extension: Hashable {

    public var hashValue: Int {
        return hash(bytes: [UInt8(type)] + binary.bytes)
    }

}

public func ==(lhs: Extension, rhs: Extension) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

enum FormatMark: UInt8 {

    case positivefixnum = 0x00
    case fixmap         = 0x80
    case fixarray       = 0x90
    case fixstr         = 0xa0
    case `nil`          = 0xc0
    case `false`        = 0xc2
    case `true`         = 0xc3
    case bin8           = 0xc4
    case bin16          = 0xc5
    case bin32          = 0xc6
    case ext8           = 0xc7
    case ext16          = 0xc8
    case ext32          = 0xc9
    case float          = 0xca
    case double         = 0xcb
    case uint8          = 0xcc
    case uint16         = 0xcd
    case uint32         = 0xce
    case uint64         = 0xcf
    case int8           = 0xd0
    case int16          = 0xd1
    case int32          = 0xd2
    case int64          = 0xd3
    case fixext1        = 0xd4
    case fixext2        = 0xd5
    case fixext4        = 0xd6
    case fixext8        = 0xd7
    case fixext16       = 0xd8
    case str8           = 0xd9
    case str16          = 0xda
    case str32          = 0xdb
    case array16        = 0xdc
    case array32        = 0xdd
    case map16          = 0xde
    case map32          = 0xdf
    case negativefixnum = 0xe0

    static func from(byte: Byte) -> FormatMark? {
        if byte <= 0x7f { return .positivefixnum }
        if byte <= 0x8f { return .fixmap }
        if byte <= 0x9f { return .fixarray }
        if byte <= 0xbf { return .fixstr }
        if byte >= 0xe0 { return .negativefixnum }
        guard let mark = FormatMark(rawValue: byte) else { return nil }
        return mark
    }

}

private func hash(bytes: Bytes) -> Int {
    var hash = Array(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH) / sizeof(Int.self))
    bytes.withUnsafeBufferPointer { bytesp in
        hash.withUnsafeMutableBufferPointer { (hashp: inout UnsafeMutableBufferPointer<Int>) -> Void in
            CC_SHA256(UnsafePointer<Void>(bytesp.baseAddress), CC_LONG(bytes.count * sizeof(Byte.self)), UnsafeMutablePointer<UInt8>(hashp.baseAddress))
        }
    }
    
    return hash[0]
}
