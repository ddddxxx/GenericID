//
//  DefaultsPublisher.swift
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

#if canImport(Combine)

import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension UserDefaults {
    
    public func publisher<Value>(for key: DefaultsKey<Value>) -> DefaultsValuePublisher<Value> {
        return DefaultsValuePublisher(object: self, key: key)
    }
    
    public func publisher<Value: DefaultConstructible>(for key: DefaultsKey<Value>) -> Publishers.Map<UserDefaults.DefaultsValuePublisher<Value>, Value> {
        return DefaultsValuePublisher(object: self, key: key).map { $0 ?? Value() }
    }
    
    public func publisher(for keys: [DefaultsKeys]) -> MultiValuePublisher {
        let stringKeys = keys.map { $0.key }
        return MultiValuePublisher(object: self, keys: stringKeys)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension UserDefaults {
    
    public class DefaultsValuePublisher<Value>: NSObject, Publisher {
        
        public typealias Output = Value?
        public typealias Failure = Never
        
        private weak var object: UserDefaults?
        private var key: DefaultsKey<Value>
        
        private var subject = CurrentValueSubject<Value?, Never>(nil)
        private var isStarted = false
        
        init(object: UserDefaults, key: DefaultsKey<Value>) {
            self.object = object
            self.key = key
            super.init()
        }
        
        private func startObservationIfNeeded() {
            if !isStarted {
                subject.send(object?[key])
                object?.addObserver(self, forKeyPath: key.key, options: [.new], context: nil)
                isStarted = true
            }
        }
        
        deinit {
            if isStarted {
                object?.removeObserver(self, forKeyPath: key.key, context: nil)
            }
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            startObservationIfNeeded()
            subject.receive(subscriber: subscriber)
        }
        
        override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard let ourObject = self.object, object as? NSObject == ourObject else { return }
            let v = change?[.newKey].flatMap(key.deserialize)
            subject.send(v)
        }
    }
    
    public class MultiValuePublisher: NSObject, Publisher {
        
        public typealias Output = Void
        public typealias Failure = Never
        
        private weak var object: UserDefaults?
        private var keys: [String]
        
        private var subject = PassthroughSubject<Void, Never>()
        private var isStarted = false
        
        init(object: UserDefaults, keys: [String]) {
            self.object = object
            self.keys = keys
            super.init()
        }
        
        private func startObservationIfNeeded() {
            if !isStarted {
                for key in keys {
                    object?.addObserver(self, forKeyPath: key, options: [.new], context: nil)
                }
                isStarted = true
            }
        }
        
        deinit {
            if isStarted {
                for key in keys {
                    object?.removeObserver(self, forKeyPath: key, context: nil)
                }
            }
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            startObservationIfNeeded()
            subject.receive(subscriber: subscriber)
        }
        
        override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard let ourObject = self.object, object as? NSObject == ourObject else { return }
            subject.send()
        }
    }
}

#endif
