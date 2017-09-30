//
//  UnpackableTests.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 26/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import XCTest
@testable import MessagePack

class UnpackableTests: XCTestCase {

    func testUnpackingArrays() {
        var bytes = makeBytes("93 01 02 d3 ff 80 32 ed cb a9 87 70")
        let unpack: [ValueBox]? = Unpacker.unpack(bytes: bytes)?.array
        XCTAssertNotNil(unpack)
        XCTAssertEqual(unpack!.map { $0.int64! }, [1, 2, -35972800113440912])
        bytes = [0xdc, 0x01, 0x00] + (0..<0x100).map { _ in 0xc0 }
        var nilValues: [ValueBox]? = Unpacker.unpack(bytes: bytes)?.array
        XCTAssertEqual(nilValues?.count, 0x100)
        XCTAssertEqual(nilValues?.first, ValueBox.nil)
        bytes = [0xdd, 0x00, 0x01, 0x00, 0x00] + (0..<0x1_00_00).map { _ in 0xc0 }
        nilValues = Unpacker.unpack(bytes: bytes)?.array
        XCTAssertEqual(nilValues?.count, 0x1_00_00)
        XCTAssertEqual(nilValues?.first, ValueBox.nil)
    }

    func testUnpackingBinaries() {
        var data: Bytes = (0..<0x10).map { $0 }
        var bytes: Bytes = [0xc4, 0x10] + data
        var unpack = Unpacker.unpack(bytes: bytes)?.binary
        XCTAssertEqual(unpack?.bytes.count, 0x10)
        XCTAssertEqual(unpack?.bytes[0x9], 0x9)

        data = (0..<0x01_10).map { UInt8(truncatingIfNeeded: $0) }
        bytes = [0xc5, 0x01, 0x10] + data
        unpack = Unpacker.unpack(bytes: bytes)?.binary
        XCTAssertEqual(unpack?.bytes.count, 0x01_10)
        XCTAssertEqual(unpack?.bytes[0x9], 0x9)

        data = (0..<0x01_00_10).map { UInt8(truncatingIfNeeded: $0) }
        bytes = [0xc6, 0x00, 0x01, 0x00, 0x10] + data
        unpack = Unpacker.unpack(bytes: bytes)?.binary
        XCTAssertEqual(unpack?.bytes.count, 0x01_00_10)
        XCTAssertEqual(unpack?.bytes[0x9], 0x9)
    }

    func testUnpackingBools() {
        var bytes: Bytes = [0xc3]
        var unpack = Unpacker.unpack(bytes: bytes)?.bool
        XCTAssertEqual(unpack, true)
        bytes = [0xc2]
        unpack = Unpacker.unpack(bytes: bytes)?.bool
        XCTAssertEqual(unpack, false)

    }

    func testUnpackingDictionaries() {
        var testBytes = makeBytes("83 a1 61 cb 3f f2 14 7a e1 47 ae 14 a1 62 cb 40 04 51 eb 85 1e b8 52 a1 63 cb 40 09 1e b8 51 eb 85 1f")
        let unpack = Unpacker.unpack(bytes: testBytes)?.dictionary
        XCTAssertEqual(unpack?["a"], 1.13)
        XCTAssertEqual(unpack?["b"], 2.54)
        XCTAssertEqual(unpack?["c"], 3.14)

        testBytes = makeBytes("82 01 a1 61 02 a1 62")
        let unpack2 = Unpacker.unpack(bytes: testBytes)?.dictionary
        XCTAssertEqual(unpack2?[.uint64(1)], .string("a"))
        XCTAssertEqual(unpack2?[.uint64(2)], .string("b"))

        var dicBytes = (0..<0x100).flatMap { $0.packToBytes() + (-$0).packToBytes() }
        testBytes = [0xde, 1, 0] + dicBytes
        var intsDic = Unpacker.unpack(bytes: testBytes)?.dictionary
        XCTAssertEqual(intsDic?.count, 0x100)
        XCTAssertEqual(intsDic?[.uint64(0xab)], -0xab)

        dicBytes = (0..<0x1_00_00).flatMap { $0.packToBytes() + (-$0).packToBytes() }
        testBytes = [0xdf, 0, 1, 0, 0] + dicBytes
        intsDic = Unpacker.unpack(bytes: testBytes)?.dictionary
        XCTAssertEqual(intsDic?.count, 0x1_00_00)
        XCTAssertEqual(intsDic?[.uint64(0xabcd)], -0xabcd)
    }

    func testUnpackingDoubles() {
        let bytes = makeBytes("cb 40 09 21 fb 54 41 17 44")
        let unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertEqual(unpack?.double, 3.1415926535)
    }

    func testUnpackingExtensions() {
        let type = Int8(12)
        let typeByte = UInt8(bitPattern: type)
        var data: Bytes = [0x7f]
        var bytes = [0xd4, typeByte] + data
        var unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 1)

        data = [0x7f, 0xff]
        bytes = [0xd5, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 2)

        data = [0x7f, 0x8f, 0x9f, 0xaf]
        bytes = [0xd6, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 4)

        data = [0x7f, 0x8f, 0x9f, 0xaf] + [0x7f, 0x8f, 0x9f, 0xaf]
        bytes = [0xd7, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 8)

        data += [0x7f, 0x8f, 0x9f, 0xaf] + [0x7f, 0x8f, 0x9f, 0xaf]
        bytes = [0xd8, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 16)

        data = (0 ..< 0x7f).map { _ in 0x7f }
        bytes = [0xc7, 0x7f, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 0x7f)

        data = (0 ..< 0x0100).map { _ in 0x7f }
        bytes = [0xc8, 0x01, 0x00, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 0x01_00)

        data = (0 ..< 0x00_01_00_00).map { _ in 0x7f }
        bytes = [0xc9, 0x00, 0x01, 0x00, 0x00, typeByte] + data
        unpack = Unpacker.unpack(bytes: bytes)?.extension
        XCTAssertEqual(unpack?.type, type)
        XCTAssertEqual(unpack?.binary.bytes.count, 0x00_01_00_00)
    }

    func testUnpackingFloats() {
        let bytes = makeBytes("ca 40 48 00 00")
        let unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertEqual(unpack?.float, 3.125)
    }

    func testUnpackingInts() {
        var bytes = makeBytes("7f")
        var unpack = Unpacker.unpack(bytes: bytes)?.int
        XCTAssertEqual(unpack, 0x7f)

        bytes = makeBytes("d0 81")
        unpack = Unpacker.unpack(bytes: bytes)?.int
        XCTAssertEqual(unpack, -0x7f)

        bytes = makeBytes("cd ab cd")
        unpack = Unpacker.unpack(bytes: bytes)?.int
        XCTAssertEqual(unpack, 0xab_cd)

        bytes = makeBytes("d1 80 33")
        unpack = Unpacker.unpack(bytes: bytes)?.int
        XCTAssertEqual(unpack, -0x7f_cd)

        bytes = makeBytes("ce 7f cd 12 34")
        unpack = Unpacker.unpack(bytes: bytes)?.int
        XCTAssertEqual(unpack, 0x7f_cd_12_34)

        bytes = makeBytes("d2 80 32 ed cc")
        unpack = Unpacker.unpack(bytes: bytes)?.int
        XCTAssertEqual(unpack, -0x7f_cd_12_34)

        bytes = makeBytes("cf 00 00 ab cd 12 34 56 78")
        var unpack64 = Unpacker.unpack(bytes: bytes)?.int64
        XCTAssertEqual(unpack64, 0xab_cd_12_34_56_78)

        bytes = makeBytes("d3 ff 80 32 ed cb a9 87 70")
        unpack64 = Unpacker.unpack(bytes: bytes)?.int64
        XCTAssertEqual(unpack64, -0x7f_cd_12_34_56_78_90)
    }

    func testUnpackingNil() {
        let bytes: Bytes = [0xc0]
        let unpack = Unpacker.unpack(bytes: bytes)?.isNil
        XCTAssertEqual(unpack, true)
    }

    func testUnpackingStrings() {
        var bytes = makeBytes("a6 e7 ac 91 63 72 79")
        var unpack = Unpacker.unpack(bytes: bytes)?.string
        XCTAssertEqual(unpack, "笑cry")

        let sample = "白日依山尽，黄河入海流"
        bytes = makeBytes("d9 21 e7 99 bd e6 97 a5 e4 be 9d e5 b1 b1 e5 b0 bd ef bc 8c e9 bb 84 e6 b2 b3 e5 85 a5 e6 b5 b7 e6 b5 81")
        unpack = Unpacker.unpack(bytes: bytes)?.string
        XCTAssertEqual(unpack, sample)

        var str16 = sample
        repeat {
            str16 += str16
        } while str16.utf8.count < 0x01_00
        bytes = [0xda, Byte(truncatingIfNeeded: str16.utf8.count >> 8), Byte(truncatingIfNeeded: str16.utf8.count)] + str16.utf8
        unpack = Unpacker.unpack(bytes: bytes)?.string
        XCTAssertTrue(unpack?.hasPrefix(sample) == true)

        var str32 = str16
        repeat {
            str32 += str32
        } while str32.utf8.count < 0x00_01_00_00
        bytes = [0xdb, Byte(truncatingIfNeeded: str32.utf8.count >> 24), Byte(truncatingIfNeeded: str32.utf8.count >> 16), Byte(truncatingIfNeeded: str32.utf8.count >> 8), Byte(truncatingIfNeeded: str32.utf8.count)] + str32.utf8
        unpack = Unpacker.unpack(bytes: bytes)?.string
        XCTAssertTrue(unpack?.hasPrefix(sample) == true)
    }

    func testUnpackingInvalidBytes() {
        var bytes: Bytes = [0xc1, 0xc2, 0xff]
        var unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertNil(unpack)

        bytes = makeBytes("81 61 93 01 02")
        unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertNil(unpack)

        bytes = makeBytes("a4 f0 98 b3")
        unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertNil(unpack)
    }

    func testUnpackingEmptyBytes() {
        let bytes: Bytes = []
        let unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertNil(unpack)
    }

    func testUnpackingInsufficientBytes() {
        var bytes = makeBytes("93 01 02")
        var unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertNil(unpack)
        bytes = makeBytes("81 a1 61 93 01 02")
        unpack = Unpacker.unpack(bytes: bytes)
        XCTAssertNil(unpack)
    }

    func testUnpackingToStdTypes() {
        var bytes = makeBytes("c3")
        let b: Bool? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(b, true)

        bytes = makeBytes("cb 40 09 21 fb 54 41 17 44")
        let d: Double? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(d, 3.1415926535)
        let dAsF: Float? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(dAsF, Float(3.1415926535))

        bytes = makeBytes("ca 3e 00 00 00")
        let f: Float? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(f, 0.125)
        let fAsD: Double? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(fAsD, 0.125)

        let uint = UInt(0x10101010)
        bytes = makeBytes("ce 10 10 10 10")
        let u: UInt? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(u, uint)
        let uAsD: Double? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(uAsD, Double(uint))
        let uAsF: Float? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(uAsF, Float(uint))

        let int = -0x07101010
        bytes = makeBytes("d2 f8 ef ef f0")
        let i: Int? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(i, int)
        let iAsD: Double? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(iAsD, Double(int))
        let iAsF: Float? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(iAsF, Float(int))

        bytes = makeBytes("a4 f0 9f 98 87")
        let s: String? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertEqual(s, "😇")
        let sAsArr = Unpacker.unpack(bytes: bytes)?.array
        XCTAssertNil(sAsArr)
        let sAsDic = Unpacker.unpack(bytes: bytes)?.dictionary
        XCTAssertNil(sAsDic)

        bytes = makeBytes("c0")
        let n: Int? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertNil(n)

        bytes = makeBytes("c4 01 7f")
        let undef: Bool? = Unpacker.unpack(bytes: bytes)?.value()
        XCTAssertNil(undef)

        bytes = makeBytes("93 01 02 03")
        let ints = Unpacker.unpack(bytes: bytes)?.array
        XCTAssertNotNil(ints)
        XCTAssertEqual(ints!.map { $0.int! }, [1, 2, 3])

        bytes = makeBytes("81 a1 61 01")
        let dic = Unpacker.unpack(bytes: bytes)
        XCTAssertNotNil(dic)
        XCTAssertEqual(dic?.value(for: "a"), 1)
    }

}
