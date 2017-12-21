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
    
    public class DefaultKeys: StaticKeyBase {
        
        public private(set) var valueTransformer: ValueTransformer?
        
        public override init(_ key: String) {
            super.init(key)
        }
        
        public init(_ key: String, transformer: ValueTransformer) {
            self.valueTransformer = transformer
            super.init(key)
        }
        
        func serialize(_ v: Any) -> Any? {
            fatalError("Must override")
        }
        
        func deserialize(_ v: Any) -> Any? {
            fatalError("Must override")
        }
    }
}

extension UserDefaults.DefaultKeys {
    
    public final class Key<T>: UserDefaults.DefaultKeys {
        
        override func serialize(_ v: Any) -> Any? {
            guard let t = valueTransformer else { return v }
            return t.serialize(v)
        }
        
        override func deserialize(_ v: Any) -> Any? {
            guard let t = valueTransformer else { return v }
            guard let data = v as? Data else { return nil }
            return t.deserialize(T.self, from: data)
        }
    }
}

extension UserDefaults.DefaultKeys.Key: ExpressibleByStringLiteral {
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}

extension UserDefaults {
    
    public func contains<T>(_ key: DefaultKey<T>) -> Bool {
        if T.self is DefaultConstructible.Type,
            !(T.self is OptionalProtocol.Type) {
            return true
        }
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
            if let transformer = key.valueTransformer {
                dict[key.key] = transformer.serialize(value)
            } else {
                dict[key.key] = value
            }
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
            return object(forKey: key.key).flatMap(key.deserialize) as? T
        }
        set {
            set(newValue.flatMap(key.serialize), forKey: key.key)
        }
    }
    
    public subscript<T>(_ key: DefaultKey<T?>) -> T? {
        get {
            return object(forKey: key.key).flatMap(key.deserialize) as? T
        }
        set {
            set(newValue.flatMap(key.serialize), forKey: key.key)
        }
    }
    
    public subscript<T: DefaultConstructible>(_ key: DefaultKey<T>) -> T {
        get {
            return object(forKey: key.key).flatMap(key.deserialize) as? T ?? T()
        }
        set {
            set(key.serialize(newValue), forKey: key.key)
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
        
        weak var object: UserDefaults?
        let callback: Callback
        let paths: [String]
        
        static var swizzler: KeyValueObservation? = {
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
        
        fileprivate init(object: UserDefaults, paths: [String], callback: @escaping Callback) {
            let _ = KeyValueObservation.swizzler
            self.paths = paths
            self.object = object
            self.callback = callback
        }
        
        deinit {
            invalidate()
        }
        
        fileprivate func start(_ options: NSKeyValueObservingOptions) {
            for path in paths {
                object?.addObserver(self, forKeyPath: path, options: options, context: nil)
            }
        }
        
        public func invalidate() {
            for path in paths {
                object?.removeObserver(self, forKeyPath: path, context: nil)
            }
            object = nil
        }
        
        @objc func _swizzle_defaults_observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
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
    
    public func observe<T>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, paths: [key.key]) { (defaults, change) in
            let newValue = change.newValue.flatMap(key.deserialize) as? T
            let oldValue = change.oldValue.flatMap(key.deserialize) as? T
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
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, paths: [key.key]) { (defaults, change) in
            let newValue = change.newValue.flatMap(key.deserialize) as? T ?? T()
            let oldValue = change.oldValue.flatMap(key.deserialize) as? T ?? T()
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
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T?>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, paths: [key.key]) { (defaults, change) in
            let newValue = change.newValue.flatMap(key.deserialize) as? T ?? T()
            let oldValue = change.oldValue.flatMap(key.deserialize) as? T ?? T()
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
    
    public func observe(keys: [DefaultKeys], options: NSKeyValueObservingOptions = [], changeHandler: @escaping () -> Void) -> KeyValueObservation {
        let paths = keys.map { $0.key }
        let result = KeyValueObservation(object: self, paths: paths) { (defaults, change) in
            changeHandler()
        }
        result.start(options)
        return result
    }
    
    public func willChangeValue<T>(for key: DefaultKey<T>) {
        self.willChangeValue(forKey: key.key)
    }
    
    public func willChange<T>(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, for key: DefaultKey<T>) {
        self.willChange(changeKind, valuesAt: indexes, forKey: key.key)
    }
    
    public func willChangeValue<T>(for key: DefaultKey<T>, withSetMutation mutation: NSKeyValueSetMutationKind, using set: Set<T>) -> Void {
        self.willChangeValue(forKey: key.key, withSetMutation: mutation, using: set)
    }
    
    public func didChangeValue<T>(for key: DefaultKey<T>) {
        self.didChangeValue(forKey: key.key)
    }
    
    public func didChange<T>(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, for key: DefaultKey<T>) {
        self.didChange(changeKind, valuesAt: indexes, forKey: key.key)
    }
    
    public func didChangeValue<T>(for key: DefaultKey<T>, withSetMutation mutation: NSKeyValueSetMutationKind, using set: Set<T>) -> Void {
        self.didChangeValue(forKey: key.key, withSetMutation: mutation, using: set)
    }
    
}
