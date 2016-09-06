//
//  DataTests.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 28/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import XCTest
@testable import MessagePack

class DataTests: XCTestCase {
    
    func testUnpackingToArrayWithValueBoxs() {
        let bytes = makeBytes("95 01 02 03 04 05")
        let data = Data(bytes: bytes)
        let box = data.unpack()
        let array = box?.array
        XCTAssertNotNil(array)
        XCTAssertEqual(array!, [1, 2, 3, 4, 5].map(ValueBox.uint64))
    }

    func testUnpackingToStdTypes() {
        let bytes = makeBytes("ad 68 65 6c 6c 6f 2c 20 77 6f 72 6c 64 21")
        let data = Data(bytes: bytes)
        let val: String? = data.unpack()?.string
        XCTAssertEqual(val, "hello, world!")
    }

    func testUnpackingToArrayWithStdTypes() {
        let bytes = makeBytes("95 a1 31 a1 32 a1 33 a1 34 a1 35")
        let data = Data(bytes: bytes)
        let val: [ValueBox]? = data.unpack()?.array
        XCTAssertNotNil(val)
        XCTAssertEqual(val!, ["1", "2", "3", "4", "5"])
    }

    func testUnpackingToDictionaryWithStdTypes() {
        let bytes = makeBytes("82 a1 61 01 a1 62 02")
        let data = Data(bytes: bytes)
        let box = data.unpack()
        XCTAssertNotNil(box)
        XCTAssertEqual(box?.value(for: "a"), 1)
        XCTAssertEqual(box?.value(for: "b"), 2)
    }

    func testPackingToData() {
        var bytes = "str".packToBytes()
        var data = "str".pack()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        bytes = [1, 2, 3].packToBytes()
        data = [1, 2, 3].pack()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
           XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        bytes = ["a": 1].packToBytes()
        data = ["a": 1].pack()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        var a: Int? = nil
        bytes = a.packToBytes()
        data = a.pack()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        a = 100
        bytes = a.packToBytes()
        data = a.pack()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }
    }

}
