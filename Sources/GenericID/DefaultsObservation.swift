//
//  DefaultsObservation.swift
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

public protocol DefaultsObservation {
    func invalidate()
}

extension UserDefaults {
    
    class _KeyValueObservedChange {
        
        let kind: NSKeyValueChange
        let indexes: IndexSet?
        let isPrior:Bool
        let newValue: Any?
        let oldValue: Any?
        
        init(observedChange change: [NSKeyValueChangeKey: Any]) {
            let rawKind = change[.kindKey] as! UInt
            kind = NSKeyValueChange(rawValue: rawKind)!
            indexes = change[.indexesKey] as? IndexSet
            isPrior = change[.notificationIsPriorKey] as? Bool ?? false
            oldValue = change[.oldKey]
            newValue = change[.newKey]
        }
    }
    
    public struct KeyValueObservedChange<T> {
        
        let _change: _KeyValueObservedChange
        let _transformer: (Any) -> T?
        
        public var kind: NSKeyValueChange { return _change.kind }
        public var indexes: IndexSet? { return _change.indexes }
        public var isPrior:Bool { return _change.isPrior }
        
        public private(set) lazy var newValue: T? = _change.newValue.flatMap(_transformer)
        public private(set) lazy var oldValue: T? = _change.oldValue.flatMap(_transformer)
        
        fileprivate init(_ change: _KeyValueObservedChange, transformer: @escaping (Any) -> T?) {
            _change = change
            _transformer = transformer
        }
    }
    
    public struct ConstructedKeyValueObservedChange<T> {
        
        let _change: _KeyValueObservedChange
        let _transformer: (Any?) -> T
        
        public var kind: NSKeyValueChange { return _change.kind }
        public var indexes: IndexSet? { return _change.indexes }
        public var isPrior:Bool { return _change.isPrior }
        
        public private(set) lazy var newValue: T = _transformer(_change.newValue)
        public private(set) lazy var oldValue: T = _transformer(_change.oldValue)
        
        fileprivate init(_ change: _KeyValueObservedChange, transformer: @escaping (Any?) -> T) {
            _change = change
            _transformer = transformer
        }
    }
    
    class SingleKeyObservation: NSObject, DefaultsObservation {
        
        typealias Callback = (UserDefaults, _KeyValueObservedChange) -> Void
        
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
            let notification = _KeyValueObservedChange(observedChange: change)
            callback(ourObject, notification)
        }
    }
}

extension UserDefaults {
    
    public func observe<T>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, inout KeyValueObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
            var notification = KeyValueObservedChange(change, transformer: key.deserialize)
            changeHandler(defaults, &notification)
        }
        result.start(options)
        return result
    }
    
    public func observe<T: DefaultConstructible>(_ key: DefaultKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, inout ConstructedKeyValueObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
            var notification = ConstructedKeyValueObservedChange(change) {
                $0.flatMap(key.deserialize) ?? T()
            }
            changeHandler(defaults, &notification)
        }
        result.start(options)
        return result
    }
}

// MARK: - Observe Multiple Keys

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
