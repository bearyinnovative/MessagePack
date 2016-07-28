//
//  Data.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import Foundation

public extension Data {

    func unpack() -> MPValue? {
        return withUnsafeBytes { (bytesp: UnsafePointer<Byte>) in
            Unpacker.unpack(bytes: Array(UnsafeBufferPointer(start: bytesp, count: self.count)))
        }
    }

    func unpack<T: UnpackableStdType>() -> T? {
        let val: MPValue? = unpack()
        return val?.value()
    }

    func unpack<T: UnpackableStdType>() -> [T]? {
        let val: MPValue? = unpack()
        return val.flatMap { $0.arrayValue() }
    }

    func unpack<K: HashableUnpackableStdType, V: UnpackableStdType>() -> [K: V]? {
        let val: MPValue? = unpack()
        return val.flatMap { $0.dictionaryValue() }
    }

}
