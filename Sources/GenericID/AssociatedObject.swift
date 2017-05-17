//
//  AssociatedObject.swift
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
