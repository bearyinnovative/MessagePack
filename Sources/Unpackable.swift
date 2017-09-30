//
//  Unpackable.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

typealias UnpackedResult = (value: ValueBox?, unpackedBytesCount: Int)

protocol Unpackable {

    static func unpack(bytes: Bytes, fromPosition: Int, mark: FormatMark) -> UnpackedResult

}

extension Array: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let (arrCount, arrStart) = _unpackInfoForArrayAndMap(bytes, pos, mark)
        guard let (arr, count) = _unpackArray(bytes, arrStart, count: arrCount) else { return (nil, 1) }
        return (arr, arrStart - pos + count)
    }

}

extension Binary: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let numBytes: Int = {
            switch mark {
            case .bin8 :
                return 1
            case .bin16:
                return 2
            default: // .bin32
                return 4
            }
        }()

        let length = Int(_uint64(from: bytes, range: pos+1 ..< pos+1+numBytes))
        let binary = Binary(bytes: Array(bytes[pos+1+numBytes ..<  pos+numBytes+1+length]))
        return (.binary(binary), 1+numBytes+length)
    }

}

extension Bool: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        switch mark {
        case .true:
            return (.bool(true), 1)
        default: // .false
            return (.bool(false), 1)
        }
    }

}

extension Dictionary: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let (dicCount, dicStart) = _unpackInfoForArrayAndMap(bytes, pos, mark)
        guard
            let (box, count) = _unpackArray(bytes, dicStart, count: dicCount*2),
            let array = box?.array
        else { return (nil, 1) }
        var dic = [ValueBox: ValueBox]()
        stride(from: 0, to: array.count, by: 2).forEach { dic[array[$0]] = array[$0+1] }
        return (.dictionary(dic), dicStart - pos + count)
    }

}

extension Double: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let dblBytes = _uint64(from: bytes, range: pos+1 ..< pos+9)
        let dblValue = Double(bitPattern: dblBytes)
        return (.double(dblValue), 9)
    }

}

extension Extension: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let lenBytesLen: Int = {
            switch mark {
            case .ext8:
                return 1
            case .ext16:
                return 2
            case .ext32:
                return 4
            default: // .fixext[1, 2, 4, 8, 16]
                return 0
            }
        }()

        let bytesLen: Int = {
            switch lenBytesLen {
            case 0:
                switch mark {
                case .fixext1:
                    return 1
                case .fixext2:
                    return 2
                case .fixext4:
                    return 4
                case .fixext8:
                    return 8
                default: // .fixext16
                    return 16
                }
            case 1:
                return Int(bytes[pos+1])
            case 2:
                return Int(_uint64(from: bytes, range: pos+1 ..< pos+3))
            default: // 4
                return Int(_uint64(from: bytes, range: pos+1 ..< pos+5))
            }
        }()

        let type = Int8(bitPattern: bytes[pos+lenBytesLen+1])
        let bytes = Array(bytes[pos+lenBytesLen+2 ..< pos+lenBytesLen+2+bytesLen])
        let ext = Extension(type: type, binary: Binary(bytes: bytes))
        return (.extension(ext), 1 + lenBytesLen + 1 + bytesLen)
    }

}

extension Float: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let fltBytes = _uint64(from: bytes, range: pos+1 ..< pos+5)
        let fltValue = Float(bitPattern: UInt32(truncatingIfNeeded:fltBytes))
        return (.float(fltValue), 5)
    }

}

extension Int64: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let (val, count): (Int64, Int) = {
            switch mark {
            case .negativefixnum:
                return (Int64(bytes[pos]) - 0x100, 1)
            case .int8:
                return (Int64(Int8(bitPattern: bytes[pos+1])), 2)
            case .int16:
                let uint = _uint64(from: bytes, range: pos+1 ..< pos+3)
                return (Int64(Int16(bitPattern: UInt16(truncatingIfNeeded: uint))), 3)
            case .int32:
                let uint = _uint64(from: bytes, range: pos+1 ..< pos+5)
                return (Int64(Int32(bitPattern: UInt32(truncatingIfNeeded: uint))), 5)
            default: // .int64
                let uint = _uint64(from: bytes, range: pos+1 ..< pos+9)
                return (Int64(bitPattern: uint), 9)
            }
        }()

        return (.int64(val), count)
    }

}

struct NilUnpacker: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        return (.nil, 1)
    }

}

extension String: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {

        let (strBytesCount, strstart): (Int, Int) = {
            switch mark {
            case .fixstr:
                return (numericCast(bytes[pos] - 0xa0), pos+1)
            case .str8:
                return (numericCast(bytes[pos+1]), pos+2)
            case .str16:
                return (numericCast(_uint64(from: bytes, range: pos+1 ..< pos+3)), pos+3)
            default: // .str32
                return (numericCast(_uint64(from: bytes, range: pos+1 ..< pos+5)), pos+5)
            }
        }()

        let count = strBytesCount + strstart - pos
        guard
            let safeBytes = bytes[safe: strstart ..< strstart + strBytesCount],
            let str = String(bytes: safeBytes, encoding: .utf8)
        else { return (nil, 1) }
        return (.string(str), count)
    }

}

extension UInt64: Unpackable {

    static func unpack(bytes: Bytes, fromPosition pos: Int, mark: FormatMark) -> UnpackedResult {
        let (val, count): (UInt64, Int) = {
            switch mark {
            case .positivefixnum:
                return (UInt64(bytes[pos]), 1)
            case .uint8:
                return (UInt64(bytes[pos+1]), 2)
            case .uint16:
                return (UInt64(_uint64(from: bytes, range: pos+1 ..< pos+3)), 3)
            case .uint32:
                return (UInt64(_uint64(from: bytes, range: pos+1 ..< pos+5)), 5)
            default: // .uint64
                return (UInt64(_uint64(from: bytes, range: pos+1 ..< pos+9)), 9)
            }
        }()

        return (.uint64(val), count)
    }

}

public struct Unpacker { }

extension Unpacker {

    public static func unpack(bytes: Bytes) -> ValueBox? {
        return unpack(bytes: bytes, fromPosition: 0)?.value
    }

    static func unpack(bytes: Bytes, fromPosition pos: Int) -> UnpackedResult? {
        guard let mark = bytes[safe: pos].flatMap(FormatMark.from(byte:)) else { return nil }
        let unpackerType: Unpackable.Type = {
            switch mark {
            case .positivefixnum, .uint8, .uint16, .uint32, .uint64:
                return UInt64.self
            case .fixmap, .map16, .map32:
                return Dictionary<ValueBox, ()>.self
            case .fixarray, .array16, .array32:
                return Array<()>.self
            case .fixstr, .str8,.str16, .str32:
                return String.self
            case .nil:
                return NilUnpacker.self
            case .false, .true:
                return Bool.self
            case .bin8, .bin16, .bin32:
                return Binary.self
            case .ext8, .ext16, .ext32, .fixext1, .fixext2, .fixext4, .fixext8, .fixext16:
                return Extension.self
            case .float:
                return Float.self
            case .double:
                return Double.self
            case .int8, .int16, .int32, .int64, .negativefixnum:
                return Int64.self
            }
        }()

        return unpackerType.unpack(bytes: bytes, fromPosition: pos, mark: mark)
    }

}

// MARK: - Privates
private func _uint64(from bytes: Bytes, range: Range<Int>) -> UInt64 {
    let bytes: Bytes = Array(bytes[range])
    return bytes.enumerated().reduce(0) { acc, iter in
        acc | (numericCast(iter.element) as UInt64) << (numericCast((bytes.count - 1 - iter.offset) * 8) as UInt64)
    }
}

private func _unpackInfoForArrayAndMap(_ bytes: Bytes, _ pos: Int, _ mark: FormatMark) -> (arrayCount: Int, start: Int) {
    switch mark {
    case .fixarray, .fixmap:
        return (Int(bytes[pos] - mark.rawValue), pos+1)
    case .array16, .map16:
        return (numericCast(_uint64(from: bytes, range: pos+1 ..< pos+3)), pos+3)
    default: // .array32, .map32:
        return (numericCast(_uint64(from: bytes, range: pos+1 ..< pos+5)), pos+5)
    }
}

// return nil if data is invalid
private func _unpackArray(_ bytes: Bytes, _ pos: Int, count: Int) -> UnpackedResult? {
    var results = [ValueBox]()
    var markPos = pos
    for _ in 0 ..< count {
        guard
            let (unpacked, bytesCount) = Unpacker.unpack(bytes: bytes, fromPosition: markPos),
            let wrapped = unpacked
        else { return nil }
        results.append(wrapped)
        markPos += bytesCount
    }
    
    return (.array(results), markPos-pos)
}

private extension Array {
    
    subscript(safe index: Index) -> Element? {
        if index >= endIndex { return nil }
        return self[index]
    }

    subscript(safe bounds: Range<Int>) -> ArraySlice<Element>? {
        if bounds.upperBound > endIndex || bounds.lowerBound < startIndex { return nil }
        return self[bounds]
    }

}
