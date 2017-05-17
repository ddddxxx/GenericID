//
//  UserDefaultes+NSValue.swift
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

public protocol NSValueConvertable {
    
    var nsValue: NSValue { get }
    
    init(nsValue: NSValue)
}

extension UserDefaults {
    
    public func nsValue<T: NSValueConvertable>(_ key: DefaultKey<T?>) -> T? {
        guard let data = data(forKey: key.rawValue) else {
            return nil
        }
        
        let value = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSValue
        return T(nsValue: value)
    }
    
    public func set<T: NSValueConvertable>(_ value: T?, forKey key: DefaultKey<T?>) {
        let data = (value?.nsValue).map(NSKeyedArchiver.archivedData)
        set(data, forKey: key.rawValue)
    }
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
