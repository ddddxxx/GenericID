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
    
    public class DefaultKeys: StaticKeyBase {}
}

extension UserDefaults.DefaultKeys {
    
    public class Key<T>: UserDefaults.DefaultKeys, RawRepresentable, ExpressibleByStringLiteral {
        
        public var rawValue: String {
            return key
        }
        
        public required init(rawValue: String) {
            super.init(rawValue)
        }
    }
}

extension UserDefaults {
    
    public func contains<T>(_ key: DefaultKey<T>) -> Bool {
        return object(forKey: key.rawValue) != nil
    }
    
    public func remove<T>(_ key: DefaultKey<T>) {
        removeObject(forKey: key.rawValue)
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
            switch value {
            case is NSNumber, is String, is Data, is URL, is Date, is [Any], is [String: Any]:
                dict[key.key] = value
            case is NSCoding:
                dict[key.key] = NSKeyedArchiver.archivedData(withRootObject: value)
            default:
                break
            }
        }
        register(defaults: dict)
    }
    
    public func unregister<T>(_ key: DefaultKey<T>) {
        var domain = volatileDomain(forName: UserDefaults.registrationDomain)
        domain.removeValue(forKey: key.rawValue)
        setVolatileDomain(domain, forName: UserDefaults.registrationDomain)
    }
    
    public func unregisterAll() {
        setVolatileDomain([:], forName: UserDefaults.registrationDomain)
    }
}

// MARK: -

extension UserDefaults {
    
    private func number(forKey defaultName: String) -> NSNumber? {
        return object(forKey: defaultName) as? NSNumber
    }
    
    private func archive(_ newValue: Any?, forKey defaultName: String) {
        let data = newValue.map(NSKeyedArchiver.archivedData)
        set(data, forKey: defaultName)
    }
    
    private func unarchive(forKey defaultName: String) -> Any? {
        guard let data = data(forKey: defaultName) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
    
    public func jsonEncode<T>(_ newValue: T?, forKey key: DefaultKey<T?>) throws {
        let data = try JSONEncoder().encode(newValue)
        set(data, forKey: key.rawValue)
    }
    
    public func jsonDecode<T: Decodable>(forKey key: DefaultKey<T?>) throws -> T? {
        guard let data = data(forKey: key.rawValue) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Subscript

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
    
    public subscript<T: NSCoding>(_ key: DefaultKey<T?>) -> T? {
        get { return unarchive(forKey: key.rawValue) as? T }
        set { archive(newValue, forKey: key.rawValue) }
    }
    
    public subscript<T: Codable>(_ key: DefaultKey<T?>) -> T? {
        get {
            do {
                return try jsonDecode(forKey: key)
            } catch {
                #if DEGBUG
                    print(error)
                #endif
                return nil
            }
        }
        set {
            do {
                try jsonEncode(newValue, forKey: key)
            } catch {
                #if DEGBUG
                    print(error)
                #endif
            }
        }
    }
    
    public subscript<T>(_ key: DefaultKey<T?>) -> T? {
        get { return object(forKey: key.rawValue) as? T }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    public subscript<T: DefaultConstructible>(_ key: DefaultKey<T>) -> T {
        get { return object(forKey: key.rawValue) as? T ?? T.init() }
        set { set(newValue, forKey: key.rawValue) }
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
    
    public func observeArchived<T: NSCoding>(_ defaultName: DefaultKey<T?>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: defaultName.rawValue) { (defaults, change) in
            let oldValue = (change.oldValue as? Data).map(NSKeyedUnarchiver.unarchiveObject) as? T
            let newValue = (change.newValue as? Data).map(NSKeyedUnarchiver.unarchiveObject) as? T
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
    
    public func observeCoded<T: Codable>(_ defaultName: DefaultKey<T?>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: defaultName.rawValue) { (defaults, change) in
            let oldValue = (change.oldValue as? Data).map { try? JSONDecoder().decode(T.self, from: $0) } as? T
            let newValue = (change.newValue as? Data).map { try? JSONDecoder().decode(T.self, from: $0) } as? T
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
    
    public func observe<T>(_ defaultName: DefaultKey<T?>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: defaultName.rawValue) { (defaults, change) in
            let notification = KeyValueObservedChange(kind: change.kind,
                                                      newValue: change.newValue as? T,
                                                      oldValue: change.oldValue as? T,
                                                      indexes: change.indexes,
                                                      isPrior: change.isPrior)
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
    
    public func observe<T: DefaultConstructible>(_ defaultName: DefaultKey<T>, options: NSKeyValueObservingOptions, changeHandler: @escaping (UserDefaults, KeyValueObservedChange<T>) -> Void) -> KeyValueObservation {
        let result = KeyValueObservation(object: self, path: defaultName.rawValue) { (defaults, change) in
            let notification = KeyValueObservedChange(kind: change.kind,
                                                      newValue: change.newValue as? T ?? T.init(),
                                                      oldValue: change.oldValue as? T ?? T.init(),
                                                      indexes: change.indexes,
                                                      isPrior: change.isPrior)
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
    
}
