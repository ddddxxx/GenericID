//
//  NSUbiquitousKeyValueStore.swift
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

#if !os(watchOS)
    
    extension NSUbiquitousKeyValueStore {
        
        public typealias StoreKeys = UserDefaults.DefaultsKeys
        public typealias StoreKey<T> = StoreKeys.Key<T>
    }

    extension NSUbiquitousKeyValueStore {
        
        public func contains<T>(_ key: StoreKey<T>) -> Bool {
            return object(forKey: key.key) != nil
        }
        
        public func remove<T>(_ key: StoreKey<T>) {
            removeObject(forKey: key.key)
        }
        
        public func removeAll() {
            for (key, _) in dictionaryRepresentation {
                removeObject(forKey: key)
            }
        }
    }
    
    extension NSUbiquitousKeyValueStore {
        
        public subscript<T>(_ key: StoreKey<T>) -> T? {
            get {
                return object(forKey: key.key).flatMap(key.deserialize)
            }
            set {
                set(newValue.flatMap(key.serialize), forKey: key.key)
            }
        }
        
        public subscript<T: UDDefaultConstructible>(_ key: StoreKey<T>) -> T {
            get {
                return object(forKey: key.key).flatMap(key.deserialize) ?? T()
            }
            set {
                // T might be optional and holds a `nil`, which will be bridged to `NSNull`
                // and cannot be stored in NSUbiquitousKeyValueStore. We must unwrap it manually.
                set(unwrap(newValue).map(key.serialize), forKey: key.key)
            }
        }
    }
    
#endif
