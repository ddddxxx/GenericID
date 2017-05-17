//
//  Utility.swift
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

public protocol NSValueConvertable {
    
    var nsValue: NSValue { get }
    
    init(nsValue: NSValue)
}

#if os(macOS)
    
    extension CGPoint: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(point: self) }
        public init(nsValue: NSValue) { self = nsValue.pointValue }
    }
    
    extension CGSize: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(size: self) }
        public init(nsValue: NSValue) { self = nsValue.sizeValue }
    }
    
    extension CGRect: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(rect: self) }
        public init(nsValue: NSValue) { self = nsValue.rectValue }
    }
    
    extension EdgeInsets: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(edgeInsets: self) }
        public init(nsValue: NSValue) { self = nsValue.edgeInsetsValue }
    }
    
#elseif os(iOS) || os(tvOS) || os(watchOS)
    
    import UIKit
    
    extension CGPoint: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(cgPoint: self) }
        public init(nsValue: NSValue) { self = nsValue.cgPointValue }
    }
    
    extension CGVector: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(cgVector: self) }
        public init(nsValue: NSValue) { self = nsValue.cgVectorValue }
    }
    
    extension CGSize: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(cgSize: self) }
        public init(nsValue: NSValue) { self = nsValue.cgSizeValue }
    }
    
    extension CGRect: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(cgRect: self) }
        public init(nsValue: NSValue) { self = nsValue.cgRectValue }
    }
    
    extension CGAffineTransform: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(cgAffineTransform: self) }
        public init(nsValue: NSValue) { self = nsValue.cgAffineTransformValue }
    }
    
    extension UIEdgeInsets: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(uiEdgeInsets: self) }
        public init(nsValue: NSValue) { self = nsValue.uiEdgeInsetsValue }
    }
    
    extension UIOffset: NSValueConvertable {
        public var nsValue: NSValue { return NSValue(uiOffset: self) }
        public init(nsValue: NSValue) { self = nsValue.uiOffsetValue }
    }
    
#endif
