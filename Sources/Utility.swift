//
//  Utility.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

extension RawRepresentable where Self.RawValue: Hashable {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension RawRepresentable where Self.RawValue: Equatable {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension RawRepresentable where Self.RawValue == String {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

extension ExpressibleByUnicodeScalarLiteral where Self: ExpressibleByStringLiteral, Self.StringLiteralType == String {
    
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension ExpressibleByExtendedGraphemeClusterLiteral where Self: ExpressibleByStringLiteral, Self.StringLiteralType == String {
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}
