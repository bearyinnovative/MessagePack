//
//  MPValueTests.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 26/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import XCTest
@testable import MessagePack

class MPValueTests: XCTestCase {

    func testEquatables() {
        var m1: MPValue = [1, 2, 3]
        var m2: MPValue = [1, 2, 3]
        var m3: MPValue = ["1", "2", "3"]
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
        var dic: [MPValue: MPValue] = [[1]: 1]
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
        var mp: MPValue = .array([1,2,3])
        XCTAssertNotNil(mp.arrayValue())
        XCTAssertEqual(mp.arrayValue()!, [1,2,3])
        XCTAssertNil(mp.binaryValue())
        XCTAssertNil(mp.boolValue())
        XCTAssertNil(mp.dictionaryValue())
        XCTAssertNil(mp.doubleValue())
        XCTAssertNil(mp.extensionValue())
        XCTAssertNil(mp.floatValue())
        XCTAssertNil(mp.int64Value())
        XCTAssertNil(mp.intValue())
        XCTAssertNil(mp.stringValue())
        XCTAssertNil(mp.uint64Value())
        XCTAssertNil(mp.uintValue())
        XCTAssertFalse(mp.isNil())

        mp = .binary(Binary(bytes: [0x7f]))
        XCTAssertEqual(mp.binaryValue(), Binary(bytes: [0x7f]))

        mp = .bool(true)
        XCTAssertEqual(mp.boolValue(), true)

        mp = .dictionary([1: 1])
        XCTAssertNotNil(mp.dictionaryValue())
        XCTAssertEqual(mp.dictionaryValue()!, [1: 1])

        mp = .double(4.5123)
        XCTAssertEqual(mp.doubleValue(), 4.5123)
        XCTAssertEqual(mp.floatValue(), Float(4.5123))
        XCTAssertEqual(mp.int64Value(), Int64(4.5123))
        XCTAssertEqual(mp.uint64Value(), UInt64(4.5123))

        mp = .double(-4.5123)
        XCTAssertEqual(mp.doubleValue(), -4.5123)
        XCTAssertEqual(mp.floatValue(), Float(-4.5123))
        XCTAssertEqual(mp.int64Value(), Int64(-4.5123))
        XCTAssertNil(mp.uint64Value())

        mp = .extension(Extension(type:1, binary: Binary(bytes: [0x7f])))
        XCTAssertEqual(mp.extensionValue(), Extension(type:1, binary: Binary(bytes: [0x7f])))

        mp = .float(1.125)
        XCTAssertEqual(mp.floatValue(), 1.125)
        XCTAssertEqual(mp.doubleValue(), 1.125)
        XCTAssertEqual(mp.int64Value(), Int64(1.125))
        XCTAssertEqual(mp.uint64Value(), UInt64(1.125))

        mp = .float(-1.125)
        XCTAssertEqual(mp.floatValue(), -1.125)
        XCTAssertEqual(mp.doubleValue(), -1.125)
        XCTAssertEqual(mp.int64Value(), Int64(-1.125))
        XCTAssertNil(mp.uint64Value())

        mp = .int64(Int64.max)
        XCTAssertEqual(mp.int64Value(), Int64.max)
        XCTAssertEqual(mp.doubleValue(), Double(Int64.max))
        XCTAssertEqual(mp.floatValue(), Float(Int64.max))
        #if arch(i386) || arch(arm)
            XCTAssertNil(mp.intValue())
        #else
            XCTAssertNotNil(mp.intValue())
        #endif

        mp = .int64(Int64.min)
        XCTAssertEqual(mp.int64Value(), Int64.min)
        XCTAssertEqual(mp.doubleValue(), Double(Int64.min))
        XCTAssertEqual(mp.floatValue(), Float(Int64.min))
        #if arch(i386) || arch(arm)
            XCTAssertNil(mp.intValue())
        #else
            XCTAssertNotNil(mp.intValue())
        #endif

        mp = .string("str")
        XCTAssertEqual(mp.stringValue(), "str")

        mp = .uint64(UInt64.max - 100)
        XCTAssertEqual(mp.uint64Value(), UInt64.max - 100)
        XCTAssertEqual(mp.doubleValue(), Double(UInt64.max - 100))
        XCTAssertEqual(mp.floatValue(), Float(UInt64.max - 100))
        #if arch(i386) || arch(arm)
            XCTAssertNil(mp.uintValue())
        #else
            XCTAssertNotNil(mp.uintValue())
        #endif
    }

}

// MARK: - LiteralConvertibles

extension MPValueTests {

    func testArrayLiteralConvertibles() {
        let val: MPValue = [1, 2, 3]
        XCTAssertEqual(val, .array([1, 2, 3]))
    }

    func testBooleanLiteralConvertibles() {
        let val: MPValue = true
        XCTAssertEqual(val, .bool(true))
    }

    func testDictionaryLiteralConvertibles() {
        let val: MPValue = ["a": 1]
        XCTAssertEqual(val, .dictionary(["a": 1]))
    }

    func testIntegerLiteralConvertibles() {
        let val: MPValue = 5
        XCTAssertEqual(val, .int64(5))
    }

    func testNilLiteralConvertibles() {
        let val: MPValue = nil
        XCTAssertEqual(val, .nil)
    }

    func testFloatLiteralConvertibles() {
        let asInt: MPValue = 5.0
        XCTAssertEqual(asInt, .int64(5))
        let asFloat: MPValue = 0.5
        XCTAssertEqual(asFloat, .float(0.5))
        let asDouble: MPValue = 3.1415926535
        XCTAssertEqual(asDouble, .double(3.1415926535))
    }

    func testStringLiteralConvertibles() {
        let val: MPValue = "a"
        XCTAssertEqual(val, .string("a"))
    }

}
