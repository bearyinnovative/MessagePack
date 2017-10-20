//
//  PackableTests.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import XCTest
@testable import MessagePack

// packed results generate from https://github.com/mcollina/msgpack5 and http://msgpack.org/#json-to-msgpack
class PackableTests: XCTestCase {

    func testPackingArrays() {
        let ints = [-1, 2, 3, 4, -5]
        XCTAssertEqual(radix(ints.packToBytes()), "95 ff 02 03 04 fb")
        let doubles = [1.0132343436, 0.125, 2.1, -3.14]
        XCTAssertEqual(radix(doubles.packToBytes()), "94 cb 3f f0 36 35 37 0f 22 ed cb 3f c0 00 00 00 00 00 00 cb 40 00 cc cc cc cc cc cd cb c0 09 1e b8 51 eb 85 1f")
        let floats = [1.125, 0.25, -0.5].map { Float($0) }
        XCTAssertEqual(radix(floats.packToBytes()), "93 ca 3f 90 00 00 ca 3e 80 00 00 ca bf 00 00 00")
        let strs = ["😡😂", "a", "中", "ABcd"]
        XCTAssertEqual(radix(strs.packToBytes()), "94 a8 f0 9f 98 a1 f0 9f 98 82 a1 61 a3 e4 b8 ad a4 41 42 63 64")
        let uints = [0xab, 0xf1, 0xab_cd, 0x7f_ff_12_34].map { UInt($0) }
        XCTAssertEqual(radix(uints.packToBytes()), "94 cc ab cc f1 cd ab cd ce 7f ff 12 34")
        let el = Int(arc4random_uniform(0x7f))
        let arr16 = Array(repeating: el, count: 0x01_00)
        var pack = arr16.packToBytes()
        XCTAssertEqual(pack[0..<4], [FormatMark.array16.rawValue, 1, 0, numericCast(el)])
        let arr32 = Array(repeating: el, count: 0x00_01_00_00)
        pack = arr32.packToBytes()
        XCTAssertEqual(pack[0..<6], [FormatMark.array32.rawValue, 0, 1, 0, 0, numericCast(el)])
    }

    func testPackingBinaries() {
        var count = 0xcd
        let bin8 = Binary(bytes: Bytes(repeating: UInt8(arc4random_uniform(0xff)), count: count))
        XCTAssertTrue(radix(bin8.packToBytes()).hasPrefix(radix([FormatMark.bin8.rawValue])))
        XCTAssertEqual(bin8.packToBytes().count, count + 2)
        count = 0x1012
        let bin16 = Binary(bytes: Bytes(repeating: UInt8(arc4random_uniform(0xff)), count: count))
        XCTAssertTrue(radix(bin16.packToBytes()).hasPrefix(radix([FormatMark.bin16.rawValue])))
        XCTAssertEqual(bin16.packToBytes().count, count + 3)
        count = 0x10001
        let bin32 = Binary(bytes: Bytes(repeating: UInt8(arc4random_uniform(0xff)), count: count))
        XCTAssertTrue(radix(bin32.packToBytes()).hasPrefix(radix([FormatMark.bin32.rawValue])))
        XCTAssertEqual(bin32.packToBytes().count, count + 5)
    }

    func testPackingBools() {
        var b = true
        XCTAssertEqual(radix(b.packToBytes()), "c3")
        b = false
        XCTAssertEqual(radix(b.packToBytes()), "c2")
    }

    func testPackingDictionary() {
        let dic: [ValueBox: ValueBox] = ["😇": [1: true]]
        XCTAssertEqual(radix(dic.packToBytes()), "81 a4 f0 9f 98 87 81 01 c3")
        let strInt = ["a": 1]
        XCTAssertEqual(radix(strInt.packToBytes()), "81 a1 61 01")
        let intStr = [1: "a"]
        XCTAssertEqual(radix(intStr.packToBytes()), "81 01 a1 61")
    }

    func testPackingDoubles() {
        let a = 3.1415926535
        XCTAssertEqual(radix(a.packToBytes()), "cb 40 09 21 fb 54 41 17 44")
    }

    func testPackingExtensions() {
        var bytes = Bytes()
        (0..<16).forEach { _ in bytes.append(UInt8(arc4random_uniform(0xff))) }
        let type = Int8(arc4random_uniform(0x7f))
        let fix1 = Extension(type: type, binary: Binary(bytes: bytes[0..<1]))
        let typeAsByte = UInt8(bitPattern: type)
        var packed = fix1.packToBytes()
        XCTAssertEqual(packed, [FormatMark.fixext1.rawValue, typeAsByte, bytes[0]])
        let fix2 = Extension(type: type, binary: Binary(bytes: bytes[0..<2]))
        packed = fix2.packToBytes()
        XCTAssertEqual(packed, [FormatMark.fixext2.rawValue, typeAsByte] + bytes[0..<2])
        let fix4 = Extension(type: type, binary: Binary(bytes: bytes[0..<4]))
        packed = fix4.packToBytes()
        XCTAssertEqual(packed, [FormatMark.fixext4.rawValue, typeAsByte] + bytes[0..<4])
        let fix8 = Extension(type: type, binary: Binary(bytes: bytes[0..<8]))
        packed = fix8.packToBytes()
        XCTAssertEqual(packed, [FormatMark.fixext8.rawValue, typeAsByte] + bytes[0..<8])
        let fix16 = Extension(type: type, binary: Binary(bytes: bytes))
        packed = fix16.packToBytes()
        XCTAssertEqual(packed, [FormatMark.fixext16.rawValue, typeAsByte] + bytes)
        var count = 0xcd
        let bin8 = Binary(bytes: Bytes(repeating: UInt8(arc4random_uniform(0xff)), count: count))
        let ext8 = Extension(type: type, binary: bin8)
        packed = ext8.packToBytes()
        XCTAssertEqual(packed.count, count + 3)
        XCTAssertEqual(packed[0..<4], [FormatMark.ext8.rawValue, Byte(0xcd), typeAsByte, bin8.bytes[0]])
        count = 0x1012
        let bin16 = Binary(bytes: Bytes(repeating: UInt8(arc4random_uniform(0xff)), count: count))
        let ext16 = Extension(type: type, binary: bin16)
        packed = ext16.packToBytes()
        XCTAssertEqual(packed.count, count + 4)
        XCTAssertEqual(packed[0..<5], [FormatMark.ext16.rawValue, Byte(0x10), Byte(0x12), typeAsByte, bin16.bytes[0]])
        count = 0x00_01_00_01
        let bin32 = Binary(bytes: Bytes(repeating: UInt8(arc4random_uniform(0xff)), count: count))
        let ext32 = Extension(type: type, binary: bin32)
        packed = ext32.packToBytes()
        XCTAssertEqual(packed.count, count + 6)
        XCTAssertEqual(packed[0..<7], [FormatMark.ext32.rawValue, 0, 1, 0, 1, typeAsByte, bin32.bytes[0]])
    }

    func testPackingFloats() {
        let a: Float = 3.14
        XCTAssertEqual(radix(a.packToBytes()), "ca 40 48 f5 c3")
    }

    func testPackingInts() {
        var int = -3
        XCTAssertEqual(radix(int.packToBytes()), "fd")
        int = -125
        XCTAssertEqual(radix(int.packToBytes()), "d0 83")
        int = -127
        XCTAssertEqual(radix(int.packToBytes()), "d0 81")
        int = -375
        XCTAssertEqual(radix(int.packToBytes()), "d1 fe 89")
        int = -45687
        XCTAssertEqual(radix(int.packToBytes()), "d2 ff ff 4d 89")
        let int64 = Int64.min + Int64(100)
        XCTAssertEqual(radix(int64.packToBytes()), "d3 80 00 00 00 00 00 00 64")
    }

    func testPackingValueBoxs() {
        let mpVals: [ValueBox] = [1, "a", 4, true, 5, nil, 5.0, 3.1415926535, [1, "a"], ["k": 1], ["2": "f"], .binary(Binary(bytes: [0x7f])), .extension(Extension(type: 0x01, binary: Binary(bytes: [0x7f]))), 0.125, .uint64(UInt64.max)]
        XCTAssertEqual(radix(mpVals.packToBytes()), "9f 01 a1 61 04 c3 05 c0 05 cb 40 09 21 fb 54 41 17 44 92 01 a1 61 81 a1 6b 01 81 a1 32 a1 66 c4 01 7f d4 01 7f ca 3e 00 00 00 cf ff ff ff ff ff ff ff ff")
    }

    func testPackingNil() {
        var n: Int? = nil
        XCTAssertEqual(radix(n.packToBytes()), "c0")
        n = 100
        XCTAssertEqual(radix(n.packToBytes()), "64")
    }

    func testPackingStrings() {
        let a = "abcdefg"
        XCTAssertEqual(radix(a.packToBytes()), "a7 61 62 63 64 65 66 67")
        let b = "中文"
        XCTAssertEqual(radix(b.packToBytes()), "a6 e4 b8 ad e6 96 87")
        let c = "🤓☢☛㉿🇨🇦中Ef"
        let exp = "ba f0 9f a4 93 e2 98 a2 e2 98 9b e3 89 bf f0 9f 87 a8 f0 9f 87 a6 e4 b8 ad 45 66"
        XCTAssertEqual(radix(c.packToBytes()), exp)
        var str8 = c
        repeat {
            str8 += c
        } while str8.utf8.count < 31 + 24
        var packed = str8.packToBytes()
        XCTAssertEqual(packed[0..<c.utf8.count+2], [FormatMark.str8.rawValue, Byte(str8.utf8.count)] + c.utf8)
        var str16 = c
        repeat {
            str16 += c
        } while str16.utf8.count < 0xff + 24
        packed = str16.packToBytes()
        XCTAssertEqual(packed[0..<c.utf8.count+3], [FormatMark.str16.rawValue, Byte(truncatingIfNeeded: str16.utf8.count >> 8), Byte(truncatingIfNeeded: str16.utf8.count)] + c.utf8)
        var str32 = c
        repeat {
            str32 += c
        } while str32.utf8.count < 0xffff + 24
        packed = str32.packToBytes()
        let expBytes = [FormatMark.str32.rawValue, Byte(truncatingIfNeeded: str32.utf8.count >> 24), Byte(truncatingIfNeeded: str32.utf8.count >> 16), Byte(truncatingIfNeeded: str32.utf8.count >> 8), Byte(truncatingIfNeeded: str32.utf8.count)] + c.utf8
        XCTAssertEqual(Array(packed[0..<c.utf8.count+5]), expBytes)
    }

    func testPackingUInts() {
        var uint = 12
        XCTAssertEqual(radix(uint.packToBytes()), "0c")
        uint = 127
        XCTAssertEqual(radix(uint.packToBytes()), "7f")
        uint = 234
        XCTAssertEqual(radix(uint.packToBytes()), "cc ea")
        uint = 65432
        XCTAssertEqual(radix(uint.packToBytes()), "cd ff 98")
        uint = 87654321
        XCTAssertEqual(radix(uint.packToBytes()), "ce 05 39 7f b1")
        let uint64 = UInt64.max - UInt64(0x1234)
        XCTAssertEqual(radix(uint64.packToBytes()), "cf ff ff ff ff ff ff ed cb")
    }

}
