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
        
        public typealias StoreKey<T> = StoreKeys.Key<T>
        public typealias ArchivedKey<T> = StoreKeys.ArchivedKey<T> // where T: NSCoding
        public typealias JSONCodedKey<T> = StoreKeys.JSONCodedKey<T> where T: Codable
        
        public class StoreKeys: StaticKeyBase {
            
            class func serialize(_ value: Any) -> Any? {
                fatalError("Must override")
            }
            
            class func deserialize(_ value: Any) -> Any? {
                fatalError("Must override")
            }
        }
    }

    extension NSUbiquitousKeyValueStore.StoreKeys {
        
        public class Key<T>: NSUbiquitousKeyValueStore.StoreKeys, RawRepresentable, ExpressibleByStringLiteral {
            
            public var rawValue: String {
                return key
            }
            
            public required init(rawValue: String) {
                super.init(rawValue)
            }
            
            override class func serialize(_ value: Any) -> Any? {
                return value
            }
            
            override class func deserialize(_ value: Any) -> Any? {
                return value
            }
        }
        
        final public class ArchivedKey<T>: Key<T> /* where T: NSCoding */ {
            
            override class func serialize(_ value: Any) -> Any? {
                guard let value = value as? T else {
                    fatalError("Should never be reached")
                }
                return NSKeyedArchiver.archivedData(withRootObject: value)
            }
            
            override class func deserialize(_ value: Any) -> Any? {
                guard let data = value as? Data else { return nil }
                return NSKeyedUnarchiver.unarchiveObject(with: data)
            }
        }
        
        final public class JSONCodedKey<T>: Key<T> where T: Codable {
            
            override class func serialize(_ value: Any) -> Any? {
                guard let value = value as? T else {
                    fatalError("Should never be reached")
                }
                return try? JSONEncoder().encode(value)
            }
            
            override class func deserialize(_ value: Any) -> Any? {
                guard let data = value as? Data else { return nil }
                return try? JSONDecoder().decode(T.self, from: data)
            }
        }
    }

    extension NSUbiquitousKeyValueStore {
        
        public func contains<T>(_ key: StoreKey<T>) -> Bool {
            return object(forKey: key.rawValue) != nil
        }
        
        public func remove<T>(_ key: StoreKey<T>) {
            removeObject(forKey: key.rawValue)
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
                return object(forKey: key.rawValue).flatMap(type(of: key).deserialize) as? T
            }
            set {
                set(newValue.flatMap(type(of: key).serialize), forKey: key.key)
            }
        }
        
        public subscript<T>(_ key: StoreKey<T?>) -> T? {
            get {
                return object(forKey: key.rawValue).flatMap(type(of: key).deserialize) as? T
            }
            set {
                set(newValue.flatMap(type(of: key).serialize), forKey: key.key)
            }
        }
        
        public subscript<T: DefaultConstructible>(_ key: StoreKey<T>) -> T {
            get {
                return object(forKey: key.rawValue).flatMap(type(of: key).deserialize) as? T ?? T()
            }
            set {
                set(type(of: key).serialize(newValue), forKey: key.key)
            }
        }
    }
    
#endif
