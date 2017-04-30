//
//  AssociatedObject.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

extension NSObject {
    
    public typealias AssociateKey<T> = AssociateKeys.Key<T>
    
    public class AssociateKeys {}
}

extension NSObject.AssociateKeys {
    
    public class Key<T>: NSObject.AssociateKeys, RawRepresentable {
        
        public let rawValue: String
        
        public required init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension NSObject.AssociateKey: Hashable, ExpressibleByStringLiteral {}

extension NSObject.AssociateKey {
    
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
    
    public func associatedValue<T>(for key: AssociateKey<T>) -> T? {
        return objc_getAssociatedObject(self, key.opaqueKey) as? T
    }
    
    public func set<T>(_ associatedValue: T, for key: AssociateKey<T>, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_COPY_NONATOMIC) {
        objc_setAssociatedObject(self, key.opaqueKey, associatedValue, policy)
    }
    
    public func removeAssociateValue<T>(for key: AssociateKey<T>) {
        objc_setAssociatedObject(self, key.opaqueKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
    
    public func removeAssociateValues() {
        objc_removeAssociatedObjects(self)
    }
}
