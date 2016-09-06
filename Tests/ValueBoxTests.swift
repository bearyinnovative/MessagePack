//
//  ValueBoxTests.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 26/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import XCTest
@testable import MessagePack

class ValueBoxTests: XCTestCase {

    func testEquatables() {
        var m1: ValueBox = [1, 2, 3]
        var m2: ValueBox = [1, 2, 3]
        var m3: ValueBox = ["1", "2", "3"]
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = .binary(Binary(bytes: [0x7f]))
        m2 = .binary(Binary(bytes: [0x7f]))
        m3 = .binary(Binary(bytes: [0x6f]))
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = true
        m2 = true
        m3 = false
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = ["a": 0.25]
        m2 = ["a": 0.25]
        m3 = ["a": 3.1415926]
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = 0.112
        m2 = 0.112
        m3 = 0.211
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = .extension(Extension(type: 1, binary: Binary(bytes: [0x7f])))
        m2 = .extension(Extension(type: 1, binary: Binary(bytes: [0x7f])))
        m3 = .extension(Extension(type: 2, binary: Binary(bytes: [0x7f])))
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = .float(0.112)
        m2 = .float(0.112)
        m3 = .float(0.211)
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = .int64(Int64.max-1)
        m2 = .int64(Int64.max-1)
        m3 = .int64(Int64.max-2)
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = .nil
        m2 = nil
        m3 = "not nil"
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = "a"
        m2 = "a"
        m3 = "b"
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)

        m1 = .uint64(UInt64.max-1)
        m2 = .uint64(UInt64.max-1)
        m3 = .uint64(UInt64.max-2)
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)
    }

    func testHashables() {
        var dic: [ValueBox: ValueBox] = [[1]: 1]
        XCTAssertEqual(dic[[1]], 1)

        dic = [.binary(Binary(bytes: [0x7f])): true]
        XCTAssertEqual(dic[.binary(Binary(bytes: [0x7f]))], true)

        dic = [true: "a"]
        XCTAssertEqual(dic[true], "a")

        dic = [[1:1]: "b"]
        XCTAssertEqual(dic[[1:1]], "b")

        dic = [.double(1.1): 2]
        XCTAssertEqual(dic[.double(1.1)], 2)

        dic = [.extension(Extension(type: 1, binary: Binary(bytes: [0x7f]))): 3]
        XCTAssertEqual(dic[.extension(Extension(type: 1, binary: Binary(bytes: [0x7f])))], 3)

        dic = [.float(1.1): 4]
        XCTAssertEqual(dic[.float(1.1)], 4)

        dic = [.int64(Int64.max): 5]
        XCTAssertEqual(dic[.int64(Int64.max)], 5)

        dic = [.nil: "def"]
        XCTAssertEqual(dic[.nil], "def")

        dic = [.string("abc"): 6]
        XCTAssertEqual(dic[.string("abc")], 6)

        dic = [.uint64(UInt64.max): 7]
        XCTAssertEqual(dic[.uint64(UInt64.max)], 7)
    }

    func testShortcutGetters() {
        var mp: ValueBox = .array([1,2,3])
        XCTAssertNotNil(mp.array)
        XCTAssertEqual(mp.array!, [1,2,3])
        XCTAssertNil(mp.binary)
        XCTAssertNil(mp.bool)
        XCTAssertNil(mp.dictionary)
        XCTAssertNil(mp.double)
        XCTAssertNil(mp.extension)
        XCTAssertNil(mp.float)
        XCTAssertNil(mp.int64)
        XCTAssertNil(mp.int)
        XCTAssertNil(mp.string)
        XCTAssertNil(mp.uint64)
        XCTAssertNil(mp.uint)
        XCTAssertFalse(mp.isNil)

        mp = .binary(Binary(bytes: [0x7f]))
        XCTAssertEqual(mp.binary, Binary(bytes: [0x7f]))

        mp = .bool(true)
        XCTAssertEqual(mp.bool, true)

        mp = .dictionary([1: 1])
        XCTAssertNotNil(mp.dictionary)
        XCTAssertEqual(mp.dictionary!, [1: 1])

        mp = .double(4.5123)
        XCTAssertEqual(mp.double, 4.5123)
        XCTAssertEqual(mp.float, Float(4.5123))
        XCTAssertEqual(mp.int64, Int64(4.5123))
        XCTAssertEqual(mp.uint64, UInt64(4.5123))

        mp = .double(-4.5123)
        XCTAssertEqual(mp.double, -4.5123)
        XCTAssertEqual(mp.float, Float(-4.5123))
        XCTAssertEqual(mp.int64, Int64(-4.5123))
        XCTAssertNil(mp.uint64)

        mp = .extension(Extension(type:1, binary: Binary(bytes: [0x7f])))
        XCTAssertEqual(mp.extension, Extension(type:1, binary: Binary(bytes: [0x7f])))

        mp = .float(1.125)
        XCTAssertEqual(mp.float, 1.125)
        XCTAssertEqual(mp.double, 1.125)
        XCTAssertEqual(mp.int64, Int64(1.125))
        XCTAssertEqual(mp.uint64, UInt64(1.125))

        mp = .float(-1.125)
        XCTAssertEqual(mp.float, -1.125)
        XCTAssertEqual(mp.double, -1.125)
        XCTAssertEqual(mp.int64, Int64(-1.125))
        XCTAssertNil(mp.uint64)

        mp = .int64(Int64.max)
        XCTAssertEqual(mp.int64, Int64.max)
        XCTAssertEqual(mp.double, Double(Int64.max))
        XCTAssertEqual(mp.float, Float(Int64.max))
        #if arch(i386) || arch(arm)
            XCTAssertNil(mp.int)
        #else
            XCTAssertNotNil(mp.int)
        #endif

        mp = .int64(Int64.min)
        XCTAssertEqual(mp.int64, Int64.min)
        XCTAssertEqual(mp.double, Double(Int64.min))
        XCTAssertEqual(mp.float, Float(Int64.min))
        #if arch(i386) || arch(arm)
            XCTAssertNil(mp.int)
        #else
            XCTAssertNotNil(mp.int)
        #endif

        mp = .string("str")
        XCTAssertEqual(mp.string, "str")

        mp = .uint64(UInt64.max - 100)
        XCTAssertEqual(mp.uint64, UInt64.max - 100)
        XCTAssertEqual(mp.double, Double(UInt64.max - 100))
        XCTAssertEqual(mp.float, Float(UInt64.max - 100))
        #if arch(i386) || arch(arm)
            XCTAssertNil(mp.uint)
        #else
            XCTAssertNotNil(mp.uint)
        #endif
    }

}

// MARK: - Expressibles

extension ValueBoxTests {

    func testExpressibleByArrayLiterals() {
        let val: ValueBox = [1, 2, 3]
        XCTAssertEqual(val, .array([1, 2, 3]))
    }

    func testExpressibleByBooleanLiterals() {
        let val: ValueBox = true
        XCTAssertEqual(val, .bool(true))
    }

    func testExpressibleByDictionaryLiterals() {
        let val: ValueBox = ["a": 1]
        XCTAssertEqual(val, .dictionary(["a": 1]))
    }

    func testExpressibleByIntegerLiterals() {
        let val: ValueBox = 5
        XCTAssertEqual(val, .int64(5))
    }

    func testExpressibleByNilLiterals() {
        let val: ValueBox = nil
        XCTAssertEqual(val, .nil)
    }

    func testExpressibleByFloatLiterals() {
        let asInt: ValueBox = 5.0
        XCTAssertEqual(asInt, .int64(5))
        let asFloat: ValueBox = 0.5
        XCTAssertEqual(asFloat, .float(0.5))
        let asDouble: ValueBox = 3.1415926535
        XCTAssertEqual(asDouble, .double(3.1415926535))
    }

    func testExpressibleByStringLiteral() {
        let val: ValueBox = "a"
        XCTAssertEqual(val, .string("a"))
    }

}
