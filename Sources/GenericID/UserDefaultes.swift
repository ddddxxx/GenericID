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
    
    public func contains<T>(_ key: DefaultsKey<T>) -> Bool {
        if T.self is UDDefaultConstructible.Type,
            !(T.self is OptionalProtocol.Type) {
            return true
        }
        return object(forKey: key.key) != nil
    }
    
    public func remove<T>(_ key: DefaultsKey<T>) {
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
    
    public func register(defaults: [DefaultsKeys: Any]) {
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
    
    public func unregister<T>(_ key: DefaultsKey<T>) {
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
    
    public subscript<T>(_ key: DefaultsKey<T>) -> T? {
        get {
            return object(forKey: key.key).flatMap(key.deserialize)
        }
        set {
            set(newValue.flatMap(key.serialize), forKey: key.key)
        }
    }
    
    public subscript<T: UDDefaultConstructible>(_ key: DefaultsKey<T>) -> T {
        get {
            return object(forKey: key.key).flatMap(key.deserialize) ?? T()
        }
        set {
            // T might be optional and holds a `nil`, which will be bridged to `NSNull`
            // and cannot be stored in UserDefaults. We must unwrap it manually.
            set(unwrap(newValue).flatMap(key.serialize), forKey: key.key)
        }
    }
}
