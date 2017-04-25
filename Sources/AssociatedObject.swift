//
//  AssociatedObject.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

extension NSObject {
    
    public typealias AssociatedKey = AssociatedKeys.Key
    
    public class AssociatedKeys {}
}

extension NSObject.AssociatedKeys {
    
    public class Key<T>: NSObject.AssociatedKeys, RawRepresentable {
        
        public let rawValue: String
        
        public required init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension NSObject.AssociatedKey: Hashable, ExpressibleByStringLiteral {}

extension NSObject.AssociatedKey {
    
    public var opaqueKey: UnsafeRawPointer! {
        
        return UnsafeRawPointer.init(bitPattern: hashValue)
    }
}

extension NSObject {
    
    // TODO: Generic Subscripts in Swift 4.
    
//    public subscript<T>(_ associated: AssociatedKey<T>) -> T {
//        get {
//            return objc_getAssociatedObject(self, associated.key)
//        }
//        set {
//            objc_setAssociatedObject(self, associated.key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//    }
    
    public func associatedValue<T>(for key: AssociatedKey<T>) -> T? {
        return objc_getAssociatedObject(self, key.opaqueKey) as? T
    }
    
    public func set<T>(associatedValue: T, for key: AssociatedKey<T>) {
        objc_setAssociatedObject(self, key.opaqueKey, associatedValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
}
