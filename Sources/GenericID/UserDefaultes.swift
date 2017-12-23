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
    
    public class DefaultKeys {
        
        public let key: String
        
        public let valueTransformer: ValueTransformer?
        
        private init(_ key: String) {
            self.key = key
            self.valueTransformer = nil
        }
        
        private init(_ key: String, transformer: ValueTransformer) {
            self.key = key
            self.valueTransformer = transformer
        }
        
        func serialize(_ v: Any) -> Any? {
            fatalError("Must override")
        }
        
        func deserialize(_ v: Any) -> Any? {
            fatalError("Must override")
        }
    }
}

extension UserDefaults.DefaultKeys: Equatable, Hashable {
    
    public static func ==(lhs: UserDefaults.DefaultKeys, rhs: UserDefaults.DefaultKeys) -> Bool {
        guard lhs.key == rhs.key else { return false }
        switch (lhs.valueTransformer, rhs.valueTransformer) {
        case (nil, nil):            return true
        case (_, nil), (nil, _):    return false
        case let (l, r):            return type(of: l) == type(of: r)
        }
    }
    
    public var hashValue: Int {
        return key.hashValue
    }
    
}

extension UserDefaults.DefaultKeys {
    
    public final class Key<T>: UserDefaults.DefaultKeys {
        
        public override init(_ key: String) {
            super.init(key)
        }
        
        public override init(_ key: String, transformer: UserDefaults.ValueTransformer) {
            super.init(key, transformer: transformer)
        }
        
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

public protocol DefaultsObservation {
    func invalidate()
}

extension UserDefaults {
    
    public struct KeyValueObservedChange<T> {
        public typealias Kind = NSKeyValueChange
        public let kind: Kind
        public let newValue: T?
        public let oldValue: T?
        public let indexes: IndexSet?
        public let isPrior:Bool
    }
    
    class SingleKeyObservation: NSObject, DefaultsObservation {
        
        typealias Callback = (UserDefaults, KeyValueObservedChange<Any>) -> Void
        
        weak var object: UserDefaults?
        let callback: Callback
        let key: String
        
        fileprivate init(object: UserDefaults, key: String, callback: @escaping Callback) {
            self.key = key
            self.object = object
            self.callback = callback
        }
        
        deinit {
            invalidate()
        }
        
        fileprivate func start(_ options: NSKeyValueObservingOptions) {
            object?.addObserver(self, forKeyPath: key, options: options, context: nil)
        }
        
        func invalidate() {
            object?.removeObserver(self, forKeyPath: key, context: nil)
            object = nil
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
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
    
    public func observe<T>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
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
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
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
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T?>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
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
}

// MARK: Observe Multiple Keys

extension UserDefaults {
    
    class MultiKeyObservation: NSObject, DefaultsObservation {
        
        typealias Callback = () -> Void
        
        weak var object: UserDefaults?
        let callback: Callback
        let keys: [String]
        
        fileprivate init(object: UserDefaults, keys: [String], callback: @escaping Callback) {
            self.keys = keys
            self.object = object
            self.callback = callback
        }
        
        deinit {
            invalidate()
        }
        
        fileprivate func start(_ options: NSKeyValueObservingOptions) {
            for key in keys {
                object?.addObserver(self, forKeyPath: key, options: options, context: nil)
            }
        }
        
        func invalidate() {
            for key in keys {
                object?.removeObserver(self, forKeyPath: key, context: nil)
            }
            object = nil
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard let ourObject = self.object, object as? NSObject == ourObject else { return }
            callback()
        }
    }
    
    public func observe(keys: [DefaultKeys], options: NSKeyValueObservingOptions = [], changeHandler: @escaping () -> Void) -> DefaultsObservation {
        let keys = keys.map { $0.key }
        let result = MultiKeyObservation(object: self, keys: keys, callback: changeHandler)
        result.start(options)
        return result
    }
}
