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

#if os(iOS) || os(tvOS)
    
    import UIKit
    
    public protocol UINibGettable: class {
        static var nibName: String { get }
    }
    
    extension UINibGettable {
        public static var nib: UINib {
            return UINib(nibName: nibName, bundle: Bundle(for: Self.self))
        }
    }
    
    protocol UINibFromTypeGettable: UINibGettable {
        associatedtype NibType
    }
    
    extension UINibFromTypeGettable {
        public static var nibName: String {
            return String(describing: NibType.self)
        }
    }
    
#endif
