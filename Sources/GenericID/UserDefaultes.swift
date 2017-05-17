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
    
    fileprivate func number(forKey defaultName: String) -> NSNumber? {
        return object(forKey: defaultName) as? NSNumber
    }
}

// MARK: - Optional Key

extension UserDefaults {
    
    public subscript(_ key: DefaultKey<Bool?>) -> Bool? {
        get { return number(forKey: key.rawValue)?.boolValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Int?>) -> Int? {
        get { return number(forKey: key.rawValue)?.intValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Float?>) -> Float? {
        get { return number(forKey: key.rawValue)?.floatValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Double?>) -> Double? {
        get { return number(forKey: key.rawValue)?.doubleValue }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<String?>) -> String? {
        get { return string(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Data?>) -> Data? {
        get { return data(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<URL?>) -> URL? {
        get { return url(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Date?>) -> Date? {
        get { return object(forKey: key.rawValue) as? Date }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[Any]?>) -> [Any]? {
        get { return array(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[String: Any]?>) -> [String: Any]? {
        get { return dictionary(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[String]?>) -> [String]? {
        get { return stringArray(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Any?>) -> Any? {
        get { return object(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }
}

// MARK: - Non-Optional Key

extension UserDefaults {
    
    public subscript(_ key: DefaultKey<Bool>) -> Bool {
        get { return number(forKey: key.rawValue)?.boolValue ?? false }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Int>) -> Int {
        get { return number(forKey: key.rawValue)?.intValue ?? 0 }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Float>) -> Float {
        get { return number(forKey: key.rawValue)?.floatValue ?? 0 }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Double>) -> Double {
        get { return number(forKey: key.rawValue)?.doubleValue ?? 0 }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<String>) -> String {
        get { return string(forKey: key.rawValue) ?? "" }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<Data>) -> Data {
        get { return data(forKey: key.rawValue) ?? Data() }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[Any]>) -> [Any] {
        get { return array(forKey: key.rawValue) ?? [] }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[String: Any]>) -> [String: Any] {
        get { return dictionary(forKey: key.rawValue) ?? [:] }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: DefaultKey<[String]>) -> [String] {
        get { return stringArray(forKey: key.rawValue) ?? [] }
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
    
    public func unarchive<T: NSCoding>(_ key: DefaultKey<T?>) -> T? {
        guard let data = data(forKey: key.rawValue) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    public func archive<T: NSCoding>(_ newValue: T, for key: DefaultKey<T?>) {
        let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
        set(data, forKey: key.rawValue)
    }
}

// MARK: - KVO

extension UserDefaults.AssociateKeys {
    static let EventsKey: Key<[String: [UserDefaults.Observing]]> = "eventsKey"
}

extension UserDefaults {
    
    var events: [String: [Observing]] {
        get { return associatedValue(for: .EventsKey) ?? [:] }
        set { set(newValue, for: .EventsKey) }
    }
    
    @discardableResult public func addObserver<T: NSCoding>(key: DefaultKey<T?>, initial: Bool = false, using: @escaping (_ oldValue: T?, _ newValue: T?) -> Void) -> Observing {
        if !events.keys.contains(key.rawValue) {
            let option: NSKeyValueObservingOptions = initial ? [.old, .new, .initial] : [.old, .new]
            addObserver(self, forKeyPath: key.rawValue, options: option, context: nil)
            events[key.rawValue] = []
        }
        let subscription = Observing() { old, new in
            let oldValue = (old as? Data).flatMap(NSKeyedUnarchiver.unarchiveObject) as? T
            let newValue = (new as? Data).flatMap(NSKeyedUnarchiver.unarchiveObject) as? T
            using(oldValue, newValue)
        }
        events[key.rawValue]?.append(subscription)
        return subscription
    }
    
    @discardableResult public func addObserver<T>(key: DefaultKey<T>, initial: Bool = false, using: @escaping (_ oldValue: T, _ newValue: T) -> Void) -> Observing {
        if !events.keys.contains(key.rawValue) {
            let option: NSKeyValueObservingOptions = initial ? [.old, .new, .initial] : [.old, .new]
            addObserver(self, forKeyPath: key.rawValue, options: option, context: nil)
            events[key.rawValue] = []
        }
        let subscription = Observing() { old, new in
            if let old = old as? T, let new = new as? T {
                using(old, new)
            }
        }
        events[key.rawValue]?.append(subscription)
        return subscription
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        events[keyPath] = events[keyPath]?.filter { $0.isValid }
        guard let observings = events[keyPath], let change = change else { return }
        
        observings.forEach { $0.handler(change[.oldKey], change[.newKey]) }
        
        if observings.isEmpty {
            events.removeValue(forKey: keyPath)
        }
    }
}

extension UserDefaults {
    
    public class Observing {
        
        typealias HandlerType = (_ old: Any?, _ new: Any?) -> Void
        
        var handler: HandlerType
        
        var isValid = true
        
        init(_ handler: @escaping HandlerType) {
            self.handler = handler
        }
        
        public func invalidate() {
            handler = {_,_ in }
            isValid = false
        }
    }
}
