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
    
    class _DefaultsObservedChange {
        
        fileprivate let kind: NSKeyValueChange
        fileprivate let indexes: IndexSet?
        fileprivate let isPrior:Bool
        fileprivate let newValue: Any?
        fileprivate let oldValue: Any?
        
        init(observedChange change: [NSKeyValueChangeKey: Any]) {
            let rawKind = change[.kindKey] as! UInt
            kind = NSKeyValueChange(rawValue: rawKind)!
            indexes = change[.indexesKey] as? IndexSet
            isPrior = change[.notificationIsPriorKey] as? Bool ?? false
            oldValue = change[.oldKey]
            newValue = change[.newKey]
        }
    }
    
    public struct DefaultsObservedChange<T> {
        
        private let _change: _DefaultsObservedChange
        private let _oldValue: LazyReference<T?>
        private let _newValue: LazyReference<T?>
        
        public var kind: NSKeyValueChange { return _change.kind }
        public var indexes: IndexSet? { return _change.indexes }
        public var isPrior: Bool { return _change.isPrior }
        public var newValue: T? { return _newValue.value }
        public var oldValue: T? { return _oldValue.value }
        
        fileprivate init(_ change: _DefaultsObservedChange, transformer: @escaping (Any) -> T?) {
            _change = change
            _oldValue = LazyReference { change.oldValue.flatMap(transformer) }
            _newValue = LazyReference { change.newValue.flatMap(transformer) }
        }
    }
    
    public struct ConstructedDefaultsObservedChange<T> {
        
        let _change: _DefaultsObservedChange
        let _oldValue: LazyReference<T>
        let _newValue: LazyReference<T>
        
        public var kind: NSKeyValueChange { return _change.kind }
        public var indexes: IndexSet? { return _change.indexes }
        public var isPrior: Bool { return _change.isPrior }
        public var newValue: T { return _newValue.value }
        public var oldValue: T { return _oldValue.value }
        
        fileprivate init(_ change: _DefaultsObservedChange, transformer: @escaping (Any?) -> T) {
            _change = change
            _oldValue = LazyReference { transformer(change.oldValue) }
            _newValue = LazyReference { transformer(change.newValue) }
        }
    }
    
    class SingleKeyObservation: NSObject, DefaultsObservation {
        
        typealias Callback = (UserDefaults, _DefaultsObservedChange) -> Void
        
        private weak var object: UserDefaults?
        private let callback: Callback
        private let key: String
        
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
            let notification = _DefaultsObservedChange(observedChange: change)
            callback(ourObject, notification)
        }
    }
}

extension UserDefaults {
    
    public func observe<T>(_ key: DefaultsKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, DefaultsObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
            let notification = DefaultsObservedChange(change, transformer: key.deserialize)
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
    
    public func observe<T: UDDefaultConstructible>(_ key: DefaultsKey<T>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaults, ConstructedDefaultsObservedChange<T>) -> Void) -> DefaultsObservation {
        let result = SingleKeyObservation(object: self, key: key.key) { (defaults, change) in
            let notification = ConstructedDefaultsObservedChange(change) {
                $0.flatMap(key.deserialize) ?? T()
            }
            changeHandler(defaults, notification)
        }
        result.start(options)
        return result
    }
}

// MARK: - Observe Multiple Keys

extension UserDefaults {
    
    class MultiKeyObservation: NSObject, DefaultsObservation {
        
        typealias Callback = () -> Void
        
        private weak var object: UserDefaults?
        private let callback: Callback
        private let keys: [String]
        
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
    
    public func observe(keys: [DefaultsKeys], options: NSKeyValueObservingOptions = [], changeHandler: @escaping () -> Void) -> DefaultsObservation {
        let keys = keys.map { $0.key }
        let result = MultiKeyObservation(object: self, keys: keys, callback: changeHandler)
        result.start(options)
        return result
    }
}
