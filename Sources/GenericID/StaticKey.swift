//
//  StaticKey.swift
//
//  This file is part of GenericID.
//  Copyright (c) 2017 Xander Deng
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//

import Foundation

public class StaticKeyBase {
    
    let key: String
    
    init(_ key: String) {
        self.key = key
    }
}

extension StaticKeyBase: Hashable {

    public var hashValue: Int {
        return key.hashValue
    }
    
    public static func ==(lhs: StaticKeyBase, rhs: StaticKeyBase) -> Bool {
        return lhs.key == rhs.key
    }
}

extension RawRepresentable where RawValue == String {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}
