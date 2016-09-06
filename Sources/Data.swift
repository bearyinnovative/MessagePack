//
//  Data.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

import Foundation

public extension Data {

    func unpack() -> ValueBox? {
        return withUnsafeBytes { (bytesp: UnsafePointer<Byte>) in
            Unpacker.unpack(bytes: Array(UnsafeBufferPointer(start: bytesp, count: self.count)))
        }
    }

}

public extension Packable {

    func pack() -> Data {
        return Data(bytes: packToBytes())
    }

}

extension Array where Element: Packable {

    public func pack() -> Data {
        return Data(bytes: packToBytes())
    }

}

extension Dictionary where Key: Hashable, Key: Packable, Value: Packable {

    public func pack() -> Data {
        return Data(bytes: packToBytes())
    }

}

extension Optional where Wrapped: Packable {

    public func pack() -> Data {
        return Data(bytes: packToBytes())
    }

}
