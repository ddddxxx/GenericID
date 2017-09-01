//
//  UserDefaultes.swift
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

extension UserDefaults {
    
    public typealias DefaultKey<T> = DefaultKeys.Key<T>
    public typealias ArchivedKey<T> = DefaultKeys.ArchivedKey<T> // where T: NSCoding
    public typealias JSONCodedKey<T> = DefaultKeys.JSONCodedKey<T> where T: Codable
    
    public class DefaultKeys: StaticKeyBase {
        
        class func persist(_ value: Any) -> Any? {
            fatalError("Must override")
        }
        
        class func depersist(_ value: Any) -> Any? {
            fatalError("Must override")
        }
    }
}

extension UserDefaults.DefaultKeys {
    
    public class Key<T>: UserDefaults.DefaultKeys, RawRepresentable, ExpressibleByStringLiteral {
        
        public var rawValue: String {
            return key
        }
        
        public required init(rawValue: String) {
            super.init(rawValue)
        }
        
        override class func persist(_ value: Any) -> Any? {
            return value
        }
        
        override class func depersist(_ value: Any) -> Any? {
            return value
        }
    }
    
    final public class ArchivedKey<T>: Key<T> /* where T: NSCoding */ {
        
        override class func persist(_ value: Any) -> Any? {
            guard let value = value as? T else { return nil }
            return NSKeyedArchiver.archivedData(withRootObject: value)
        }
        
        override class func depersist(_ value: Any) -> Any? {
            guard let data = value as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: data)
        }
    }
    
    final public class JSONCodedKey<T>: Key<T> where T: Codable {
        override class func persist(_ value: Any) -> Any? {
            guard let value = value as? T else { return nil }
            return try? JSONEncoder().encode(value)
        }
        
        override class func depersist(_ value: Any) -> Any? {
            guard let data = value as? Data else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }
}

extension UserDefaults {
    
    public func contains<T>(_ key: DefaultKey<T>) -> Bool {
        return object(forKey: key.key) != nil
    }
    
    public func remove<T>(_ key: DefaultKey<T>) {
        removeObject(forKey: key.key)
    }
    
    public func removeAll() {
        if let appDomain = Bundle.main.bundleIdentifier {
            removePersistentDomain(forName: appDomain)
            synchronize()
        } else {
            for key in dictionaryRepresentation().keys {
                removeObject(forKey: key)
            }
        }
    }
    
    public func register(defaults: [DefaultKeys: Any]) {
        var dict = Dictionary<String, Any>(minimumCapacity: defaults.count)
        for (key, value) in defaults {
            dict[key.key] = type(of: key).persist(value)
        }
        register(defaults: dict)
    }
    
    public func unregister<T>(_ key: DefaultKey<T>) {
        var domain = volatileDomain(forName: UserDefaults.registrationDomain)
        domain.removeValue(forKey: key.key)
        setVolatileDomain(domain, forName: UserDefaults.registrationDomain)
    }
    
    public func unregisterAll() {
        setVolatileDomain([:], forName: UserDefaults.registrationDomain)
    }
}

// MARK: - Subscript

extension UserDefaults {
    
    public subscript<T>(_ key: DefaultKey<T>) -> T? {
        get {
            return object(forKey: key.rawValue).flatMap(type(of: key).depersist) as? T
        }
        set {
            set(newValue.flatMap(type(of: key).persist), forKey: key.key)
        }
    }
    
    public subscript<T>(_ key: DefaultKey<T?>) -> T? {
        get {
            return object(forKey: key.rawValue).flatMap(type(of: key).depersist) as? T
        }
        set {
            set(newValue.flatMap(type(of: key).persist), forKey: key.key)
        }
    }
    
    public subscript<T: DefaultConstructible>(_ key: DefaultKey<T>) -> T {
        get {
            return object(forKey: key.rawValue).flatMap(type(of: key).depersist) as? T ?? T()
        }
        set {
            set(type(of: key).persist(newValue), forKey: key.key)
        }
    }
}

// MARK: - KVO

extension UserDefaults {
    
    public struct KeyValueObservedChange<T> {
        public typealias Kind = NSKeyValueChange
        public let kind: Kind
        public let newValue: T?
        public let oldValue: T?
        public let indexes: IndexSet?
        public let isPrior:Bool
    }
    
    public class KeyValueObservation: NSObject {
        
        typealias Callback = (UserDefaults, KeyValueObservedChange<Any>) -> Void
        
        weak var object : UserDefaults?
        let callback : Callback
        let path : String
        
        static var swizzler : KeyValueObservation? = {
            let bridgeClass: AnyClass = KeyValueObservation.self
            let observeSel = #selector(NSObject.observeValue(forKeyPath:of:change:context:))
            let swapSel = #selector(KeyValueObservation._swizzle_defaults_observeValue(forKeyPath:of:change:context:))
            guard let rootObserveImpl = class_getInstanceMethod(bridgeClass, observeSel),
                let swapObserveImpl = class_getInstanceMethod(bridgeClass, swapSel) else {
                    fatalError("failed to swizzle method \(observeSel) and \(swapSel)")
            }
            method_exchangeImplementations(rootObserveImpl, swapObserveImpl)
            return nil
        }()
        
        fileprivate init(object: UserDefaults, path: String, callback: @escaping Callback) {
            let _ = KeyValueObservation.swizzler
            self.path = path
            self.object = object
            self.callback = callback
        }
        
        deinit {
            invalidate()
        }
        
        fileprivate func start(_ options: NSKeyValueObservingOptions) {
            object?.addObserver(self, forKeyPath: path, options: options, context: nil)
        }
        
        public func invalidate() {
            object?.removeObserver(self, forKeyPath: path, context: nil)
            object = nil
        }
        
        @objc func _swizzle_defaults_observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let ourObject = self.object, object as? NSObject == ourObject, let change = change else { return }
            let rawKind = change[.kindKey] as! UInt
            let kind = NSKeyValueChange(rawValue: rawKind)!
            let notification = KeyValueObservedChange(kind: kind,
                                                      newValue: change[.newKey],
                                                      oldValue: change[.oldKey],
                                                      indexes: change[.indexesKey] as! IndexSet?,
                                                      isPrior: change[.notificationIsPriorKey] as? Bool ?? false)
            callback(ourObject, notification)
        }
    }
}

extension UserDefaults {
    
    public func observe<T>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: key.key) { (defaults, change) in
            let newValue = change.newValue.flatMap(type(of: key).depersist) as? T
            let oldValue = change.oldValue.flatMap(type(of: key).depersist) as? T
            let notification = KeyValueObservedChange(kind: change.kind,
                                                      newValue: newValue,
                                                      oldValue: oldValue,
                                                      indexes: change.indexes,
                                                      isPrior: change.isPrior)
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: key.key) { (defaults, change) in
            let newValue = change.newValue.flatMap(type(of: key).depersist) as? T ?? T()
            let oldValue = change.oldValue.flatMap(type(of: key).depersist) as? T ?? T()
            let notification = KeyValueObservedChange(kind: change.kind,
                                                      newValue: newValue,
                                                      oldValue: oldValue,
                                                      indexes: change.indexes,
                                                      isPrior: change.isPrior)
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T?>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: key.key) { (defaults, change) in
            let newValue = change.newValue.flatMap(type(of: key).depersist) as? T ?? T()
            let oldValue = change.oldValue.flatMap(type(of: key).depersist) as? T ?? T()
            let notification = KeyValueObservedChange(kind: change.kind,
                                                      newValue: newValue,
                                                      oldValue: oldValue,
                                                      indexes: change.indexes,
                                                      isPrior: change.isPrior)
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
    
    public func willChangeValue<T>(for key: DefaultKey<T>) {
        self.willChangeValue(forKey: key.rawValue)
    }
    
    public func willChange<T>(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, for key: DefaultKey<T>) {
        self.willChange(changeKind, valuesAt: indexes, forKey: key.rawValue)
    }
    
    public func willChangeValue<T>(for key: DefaultKey<T>, withSetMutation mutation: NSKeyValueSetMutationKind, using set: Set<T>) -> Void {
        self.willChangeValue(forKey: key.rawValue, withSetMutation: mutation, using: set)
    }
    
    public func didChangeValue<T>(for key: DefaultKey<T>) {
        self.didChangeValue(forKey: key.rawValue)
    }
    
    public func didChange<T>(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, for key: DefaultKey<T>) {
        self.didChange(changeKind, valuesAt: indexes, forKey: key.rawValue)
    }
    
    public func didChangeValue<T>(for key: DefaultKey<T>, withSetMutation mutation: NSKeyValueSetMutationKind, using set: Set<T>) -> Void {
        self.didChangeValue(forKey: key.rawValue, withSetMutation: mutation, using: set)
    }
    
}
