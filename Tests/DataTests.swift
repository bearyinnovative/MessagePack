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
    
    func testUnpackingToArrayWithMPValues() {
        let bytes = makeBytes("95 01 02 03 04 05")
        let data = Data(bytes: bytes)
        let val = data.unpack()
        let array = val?.arrayValue()
        XCTAssertNotNil(array)
        XCTAssertEqual(array!, [1, 2, 3, 4, 5].map(MPValue.uint64))
    }

    func testUnpackingToStdTypes() {
        let bytes = makeBytes("ad 68 65 6c 6c 6f 2c 20 77 6f 72 6c 64 21")
        let data = Data(bytes: bytes)
        let val: String? = data.unpack()
        XCTAssertEqual(val, "hello, world!")
    }

    func testUnpackingToArrayWithStdTypes() {
        let bytes = makeBytes("95 a1 31 a1 32 a1 33 a1 34 a1 35")
        let data = Data(bytes: bytes)
        let val: [String]? = data.unpack()
        XCTAssertNotNil(val)
        XCTAssertEqual(val!, ["1", "2", "3", "4", "5"])
    }

    func testUnpackingToDictionaryWithStdTypes() {
        let bytes = makeBytes("82 a1 61 01 a1 62 02")
        let data = Data(bytes: bytes)
        let val: [String: Int]? = data.unpack()
        XCTAssertNotNil(val)
        XCTAssertEqual(val!, ["a": 1, "b": 2])
    }

    func testPackingToData() {
        var bytes = "str".pack()
        var data = "str".packToData()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        bytes = [1, 2, 3].pack()
        data = [1, 2, 3].packToData()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
           XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        bytes = ["a": 1].pack()
        data = ["a": 1].packToData()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        var a: Int? = nil
        bytes = a.pack()
        data = a.packToData()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }

        a = 100
        bytes = a.pack()
        data = a.packToData()
        data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            XCTAssertEqual(bytes, Array(UnsafeBufferPointer(start: pointer, count: data.count)))
        }
    }

}
