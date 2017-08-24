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

extension NSUbiquitousKeyValueStore {
    
    public typealias StoreKey<T> = StoreKeys.Key<T>
    
    public class StoreKeys: StaticKeyBase {}
}

extension NSUbiquitousKeyValueStore.StoreKeys {
    
    public class Key<T>: NSUbiquitousKeyValueStore.StoreKeys, RawRepresentable, ExpressibleByStringLiteral {
        
        public var rawValue: String {
            return key
        }
        
        public required init(rawValue: String) {
            super.init(rawValue)
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
    
    fileprivate func number(forKey defaultName: String) -> NSNumber? {
        return object(forKey: defaultName) as? NSNumber
    }
    
    fileprivate func unarchive(forKey defaultName: String) -> Any? {
        return data(forKey: defaultName).flatMap(NSKeyedUnarchiver.unarchiveObject)
    }
}

// MARK: - Optional Key

extension NSUbiquitousKeyValueStore {
    
    public subscript(_ key: StoreKey<Bool?>) -> Bool? {
        get { return number(forKey: key.rawValue)?.boolValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Int?>) -> Int? {
        get { return number(forKey: key.rawValue)?.intValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Float?>) -> Float? {
        get { return number(forKey: key.rawValue)?.floatValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Double?>) -> Double? {
        get { return number(forKey: key.rawValue)?.doubleValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<String?>) -> String? {
        get { return string(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Data?>) -> Data? {
        get { return data(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Date?>) -> Date? {
        get { return object(forKey: key.rawValue) as? Date }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<[Any]?>) -> [Any]? {
        get { return array(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<[String: Any]?>) -> [String: Any]? {
        get { return dictionary(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<[String]?>) -> [String]? {
        get { return array(forKey: key.rawValue) as? [String] }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Any?>) -> Any? {
        get { return object(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    // TODO: Generic Subscripts in Swift 4.
    
    public func unarchive<T: NSCoding>(_ key: StoreKey<T?>) -> T? {
        return unarchive(forKey: key.rawValue) as? T
    }
    
    public func archive<T: NSCoding>(_ newValue: T?, for key: StoreKey<T?>) {
        let data = newValue.map(NSKeyedArchiver.archivedData)
        set(data, forKey: key.rawValue)
    }
    
    public func unwrap<T: NSValueConvertable>(_ key: StoreKey<T?>) -> T? {
        return unarchive(forKey: key.rawValue).flatMap { $0 as? NSValue }.map(T.init)
    }
    
    public func wrap<T: NSValueConvertable>(_ newValue: T?, for key: StoreKey<T?>) {
        let data = (newValue?.nsValue).map(NSKeyedArchiver.archivedData)
        set(data, forKey: key.rawValue)
    }
}

// MARK: - Non-Optional Key

extension NSUbiquitousKeyValueStore {
    
    public subscript(_ key: StoreKey<Bool>) -> Bool {
        get { return number(forKey: key.rawValue)?.boolValue ?? false }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Int>) -> Int {
        get { return number(forKey: key.rawValue)?.intValue ?? 0 }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Float>) -> Float {
        get { return number(forKey: key.rawValue)?.floatValue ?? 0 }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Double>) -> Double {
        get { return number(forKey: key.rawValue)?.doubleValue ?? 0 }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<String>) -> String {
        get { return string(forKey: key.rawValue) ?? "" }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<Data>) -> Data {
        get { return data(forKey: key.rawValue) ?? Data() }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<[Any]>) -> [Any] {
        get { return array(forKey: key.rawValue) ?? [] }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<[String: Any]>) -> [String: Any] {
        get { return dictionary(forKey: key.rawValue) ?? [:] }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: StoreKey<[String]>) -> [String] {
        get { return array(forKey: key.rawValue) as? [String] ?? [] }
        set { set(newValue, forKey: key.rawValue) }
    }
}
