//
//  Packable.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

public protocol Packable {

    func packToBytes() -> Bytes

}

extension Array where Element: Packable {

    public func packToBytes() -> Bytes {
        return _collectionMarkerBytes(length: count, markers: [.fixarray, .array16, .array32]) + flatMap { $0.packToBytes() }
    }

}

extension Binary: Packable {

    public func packToBytes() -> Bytes {
        return _binaryMarkerBytes(length: bytes.count, markers: [.bin8, .bin16, .bin32]) + bytes
    }

}

extension Bool: Packable {

    public func packToBytes() -> Bytes {
        switch self {
        case true:
            return [FormatMark.`true`.rawValue]
        case false:
            return [FormatMark.`false`.rawValue]
        }
    }

}

extension Dictionary where Key: Hashable, Key: Packable, Value: Packable {

    public func packToBytes() -> Bytes {
        return _collectionMarkerBytes(length: count, markers: [.fixmap, .map16, .map32]) + flatMap { $0.packToBytes() + $1.packToBytes() }
    }

}

extension Double: Packable {

    public func packToBytes() -> Bytes {
        let intValue = unsafeBitCast(self, to: UInt64.self)
        return [FormatMark.double.rawValue] + _bytes(of: intValue)
    }

}

extension Extension: Packable {

    public func packToBytes() -> Bytes {
        let typeByte = Byte(bitPattern: type)
        let formatBytes: Bytes = {
            let count = UInt32(binary.bytes.count)
            switch count {
            case 1:
                return [FormatMark.fixext1.rawValue, typeByte]
            case 2:
                return [FormatMark.fixext2.rawValue, typeByte]
            case 4:
                return [FormatMark.fixext4.rawValue, typeByte]
            case 8:
                return [FormatMark.fixext8.rawValue, typeByte]
            case 16:
                return [FormatMark.fixext16.rawValue, typeByte]
            case let count where count <= 0xff:
                return [FormatMark.ext8.rawValue, numericCast(count), typeByte]
            case let count where count <= 0xffff:
                return [FormatMark.ext16.rawValue] + _bytes(of: UInt16(count)) + [typeByte]
            default: // count <= 0xffff_ffff:
                return [FormatMark.ext32.rawValue] + _bytes(of: UInt32(count)) + [typeByte]
            }
        }()

        return formatBytes + binary.bytes
    }

}

extension Float: Packable {

    public func packToBytes() -> Bytes {
        let intValue = unsafeBitCast(self, to: UInt32.self)
        return [FormatMark.float.rawValue] + _bytes(of: intValue)
    }

}

extension Int: Packable {

    public func packToBytes() -> Bytes {
        return Int64(self).packToBytes()
    }
    
}


extension Int64: Packable {

    public func packToBytes() -> Bytes {
        if self >= 0 { return _packPositive(int: numericCast(self)) }
        return _packNegative(int: numericCast(self))
    }

}

extension Optional where Wrapped: Packable {

    public func packToBytes() -> Bytes {
        guard let some = self else { return [FormatMark.`nil`.rawValue] }
        return some.packToBytes()
    }

}

extension String: Packable {

    public func packToBytes() -> Bytes {
        let len = utf8.count
        let formatBytes: Bytes = {
            if  len < 0x20 { return [FormatMark.fixstr.rawValue | numericCast(len) ] }
            return _binaryMarkerBytes(length: len, markers: [.str8, .str16, .str32])
        }()

        return formatBytes + utf8
    }

}

extension UInt: Packable {

    public func packToBytes() -> Bytes {
        return UInt64(self).packToBytes()
    }
}

extension UInt64: Packable {

    public func packToBytes() -> Bytes {
        return _packPositive(int: numericCast(self))
    }

}

extension MPValue: Packable {

    public func packToBytes() -> Bytes {
        switch self {
        case .array(let a):
            return a.packToBytes()
        case .binary(let b):
            return b.packToBytes()
        case .bool(let b):
            return b.packToBytes()
        case .dictionary(let d):
            return d.packToBytes()
        case .double(let d):
            return d.packToBytes()
        case .extension(let e):
            return e.packToBytes()
        case .float(let f):
            return f.packToBytes()
        case .int64(let i):
            return i.packToBytes()
        case .nil:
            return [FormatMark.`nil`.rawValue]
        case .string(let s):
            return s.packToBytes()
        case .uint64(let u):
            return u.packToBytes()
        }
    }

}

// MARK: - Privates
private func _bytes<T: UnsignedInteger>(of uint: T) -> Bytes {
    let size = UInt64(sizeofValue(uint))
    let high = 8 * (size - 1)
    return stride(from: high, through: 0, by: -8).map { Byte(truncatingBitPattern: numericCast(uint) >> $0) }
}

private func _collectionMarkerBytes(length: Int, markers: [FormatMark]) -> Bytes {
    switch length {
    case 0 ... 0xf:
        return [markers[0].rawValue | UInt8(length)]
    case 0x10 ... 0xffff:
        return [markers[1].rawValue] + _bytes(of: UInt16(length))
    default:
        return [markers[2].rawValue] + _bytes(of: UInt32(length))
    }
}

private func _binaryMarkerBytes(length: Int, markers: [FormatMark]) -> Bytes {
    switch length {
    case 0 ... 0xff:
        return [markers[0].rawValue, UInt8(length)]
    case 0x100 ... 0xffff:
        return [markers[1].rawValue] + _bytes(of: UInt16(length))
    default:
        return [markers[2].rawValue] + _bytes(of: UInt32(length))
    }
}

private func _packPositive(int: UInt64) -> Bytes {
    if int <= 0x7f        { return [FormatMark.positivefixnum.rawValue | Byte(truncatingBitPattern: int)] }
    if int <= 0xff        { return [FormatMark.uint8.rawValue, Byte(truncatingBitPattern: int)] }
    if int <= 0xffff      { return [FormatMark.uint16.rawValue] + _bytes(of: UInt16(int)) }
    if int <= 0xffff_ffff { return [FormatMark.uint32.rawValue] + _bytes(of: UInt32(int)) }
    return [FormatMark.uint64.rawValue] + _bytes(of: UInt64(int))
}

private func _packNegative(int: Int64) -> Bytes {
    if int >= -0x20        { return [FormatMark.negativefixnum.rawValue + 0x1f & Byte(truncatingBitPattern: int)] }
    if int >= -0x7f        { return [FormatMark.int8.rawValue, Byte(truncatingBitPattern: int)] }
    if int >= -0x7fff      { return [FormatMark.int16.rawValue] + _bytes(of: UInt16(bitPattern: numericCast(int))) }
    if int >= -0x7fff_ffff { return [FormatMark.int32.rawValue] + _bytes(of: UInt32(bitPattern: numericCast(int))) }
    return [FormatMark.int64.rawValue] + _bytes(of: UInt64(bitPattern: int))
}
