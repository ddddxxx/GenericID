//
//  UserDefaultes.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    public typealias DefaultKey<T> = DefaultKeys.Key<T>
    
    public class DefaultKeys {}
}

extension UserDefaults.DefaultKeys {
    
    public class Key<T>: UserDefaults.DefaultKeys, RawRepresentable {
        
        public let rawValue: String
        
        public required init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension UserDefaults.DefaultKey: Hashable, ExpressibleByStringLiteral {}

extension UserDefaults {
    
    public func contains<T>(_ key: DefaultKey<T>) -> Bool {
        return object(forKey: key.rawValue) != nil
    }
    
    public func remove<T>(_ key: DefaultKey<T>) {
        removeObject(forKey: key.rawValue)
    }
    
    public func removeAll() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
    }
}

extension UserDefaults {
    
    public subscript(_ key: DefaultKey<String>) -> String? {
        get { return string(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[Any]>) -> [Any]? {
        get { return array(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[String: Any]>) -> [String: Any]? {
        get { return dictionary(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Data>) -> Data? {
        get { return data(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[String]>) -> [String]? {
        get { return stringArray(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Int>) -> Int {
        get { return integer(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Float>) -> Float {
        get { return float(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Double>) -> Double {
        get { return double(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Bool>) -> Bool {
        get { return bool(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<URL>) -> URL? {
        get { return url(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Date>) -> Date? {
        get { return object(forKey: key.rawValue) as? Date }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Any>) -> Any? {
        get { return object(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    // TODO: Generic Subscripts in Swift 4.
    
//    public subscript<T: NSCoding>(_ key: Key<T>) -> T? {
//        get { return object(forKey: key.rawValue) }
//        set { set(newValue, forKey: key.rawValue) }
//    }
//
//    public subscript<T>(_ key: Key<T>) -> T? {
//        get { return object(forKey: key.rawValue) }
//        set { set(newValue, forKey: key.rawValue) }
//    }
    
    public func unarchive<T: NSCoding>(_ key: DefaultKey<T>) -> T? {
        guard let data = data(forKey: key.rawValue) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    public func archive<T: NSCoding>(_ newValue: T, for key: DefaultKey<T>) {
        let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
        set(data, forKey: key.rawValue)
    }
}
