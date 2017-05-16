//
//  UserDefaultes+NSValue.swift
//  GenericID
//
//  Created by 邓翔 on 2017/5/16.
//
//

import Foundation

public protocol NSValueConvertable {
    
    var nsValue: NSValue { get }
    
    init(nsValue: NSValue)
}

extension UserDefaults {
    
    public func nsValue<T: NSValueConvertable>(_ key: DefaultKey<T?>) -> T? {
        guard let value = object(forKey: key.rawValue) as? NSValue else {
            return nil
        }
        return T(nsValue: value)
    }
    
    public func set<T: NSValueConvertable>(_ value: T?, forKey key: DefaultKey<T?>) {
        set(value?.nsValue, forKey: key.rawValue)
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
