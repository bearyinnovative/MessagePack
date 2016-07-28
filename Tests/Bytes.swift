//
//  Bytes.swift
//  MessagePack
//
//  Created by CHEN Xian’an on 25/07/2016.
//  Copyright © 2016 Beary Innovative. All rights reserved.
//

@testable import MessagePack

func radix(_ bytes: Bytes, _ radix: Int = 16, _ uppercase: Bool = false) -> String {
    return bytes.map {
        let s = String($0, radix: radix, uppercase: uppercase)
        return s.characters.count == 1 ? "0\(s)" : s
        }.joined(separator: " ")
}

func makeBytes(_ hex: String) -> Bytes {
    return hex.components(separatedBy: " ").map { Byte($0, radix: 16)! }
}
