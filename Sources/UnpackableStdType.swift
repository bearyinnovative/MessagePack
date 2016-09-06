//
//  UnpackableStdType.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 26/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

public protocol UnpackableStdType {}

extension Bool: UnpackableStdType {}

extension Double: UnpackableStdType {}

extension Float: UnpackableStdType {}

extension Int: UnpackableStdType {}

extension Int64: UnpackableStdType {}

extension String: UnpackableStdType {}

extension UInt: UnpackableStdType {}

extension UInt64: UnpackableStdType {}

public extension ValueBox {

    func value<T: UnpackableStdType>() -> T? {
        switch self {
        case .bool:
            return bool as? T
        case .double:
            return double as? T
                ?? float as? T
        case .float:
            return float as? T
                ?? double as? T
        case .int64:
            return int64 as? T
                ?? uint64 as? T
                ?? int as? T
                ?? uint as? T
                ?? double as? T
                ?? float as? T
        case .nil:
            return nil
        case .string:
            return string as? T
        case .uint64:
            return uint64 as? T
                ?? int64 as? T
                ?? uint as? T
                ?? int as? T
                ?? double as? T
                ?? float as? T
        default:
            return nil
        }
    }

}
