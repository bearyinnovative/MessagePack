//
//  UnpackableStdType.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 26/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

public protocol UnpackableStdType {}

public protocol HashableUnpackableStdType: Hashable, UnpackableStdType {}

extension Bool: HashableUnpackableStdType {}

extension Double: HashableUnpackableStdType {}

extension Float: HashableUnpackableStdType {}

extension Int: HashableUnpackableStdType {}

extension Int64: HashableUnpackableStdType {}

extension String: HashableUnpackableStdType {}

extension UInt: HashableUnpackableStdType {}

extension UInt64: HashableUnpackableStdType {}

public extension MPValue {

    func value<T: UnpackableStdType>() -> T? {
        switch self {
        case .bool:
            return boolValue() as? T
        case .double:
            return doubleValue() as? T
                ?? floatValue() as? T
        case .float:
            return floatValue() as? T
                ?? doubleValue() as? T
        case .int64:
            return int64Value() as? T
                ?? uint64Value() as? T
                ?? intValue() as? T
                ?? uintValue() as? T
                ?? doubleValue() as? T
                ?? floatValue() as? T
        case .nil:
            return nil
        case .string:
            return stringValue() as? T
        case .uint64:
            return uint64Value() as? T
                ?? int64Value() as? T
                ?? uintValue() as? T
                ?? intValue() as? T
                ?? doubleValue() as? T
                ?? floatValue() as? T
        default:
            return nil
        }
    }

    func arrayValue<T: UnpackableStdType>() -> [T]? {
        guard let arr = arrayValue() else { return nil }
        var ret = [T]()
        for el in arr {
            guard let t: T = el.value() else { return nil }
            ret.append(t)
        }

        return ret
    }

    func dictionaryValue<K: HashableUnpackableStdType>() -> [K: MPValue]? {
        guard let dic = dictionaryValue() else { return nil }
        var ret = [K: MPValue]()
        for (key, val) in dic {
            guard let key: K = key.value() else { return nil }
            ret[key] = val
        }

        return ret
    }

    func dictionaryValue<K: HashableUnpackableStdType, V: UnpackableStdType>() -> [K: V]? {
        guard let dic = dictionaryValue() else { return nil }
        var ret = [K: V]()
        for (key, val) in dic {
            guard let key: K = key.value(), let val: V = val.value() else { return nil }
            ret[key] = val
        }
        
        return ret
    }

}
