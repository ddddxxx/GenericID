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

#if canImport(CXShim)

import Foundation
import CXShim

extension UserDefaults {
    
    public func publisher<Value>(for key: DefaultsKey<Value>) -> Publisher<Value> {
        return Publisher(object: self, key: key)
    }
    
    public func publisher<Value: DefaultConstructible>(for key: DefaultsKey<Value>) -> Publishers.Map<UserDefaults.Publisher<Value>, Value> {
        return Publisher(object: self, key: key).map { $0 ?? Value() }
    }
    
    public func publisher(for keys: [DefaultsKeys]) -> MultiValuePublisher {
        return MultiValuePublisher(object: self, keys: keys)
    }
}

extension UserDefaults {
    
    public struct Publisher<Value>: CXShim.Publisher {
        
        public typealias Output = Value?
        public typealias Failure = Never
        
        public let object: UserDefaults
        public let key: DefaultsKey<Value>
        
        init(object: UserDefaults, key: DefaultsKey<Value>) {
            self.object = object
            self.key = key
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = UserDefaults.Subscription(object: object, key: key, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
    
    public struct MultiValuePublisher: CXShim.Publisher {
        
        public typealias Output = Void
        public typealias Failure = Never
        
        public var object: UserDefaults
        public var keys: [DefaultsKeys]
        
        init(object: UserDefaults, keys: [DefaultsKeys]) {
            self.object = object
            self.keys = keys
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = UserDefaults.MultiValueSubscription(object: object, keys: keys, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

private extension UserDefaults {
    
    final class Subscription<Output, Downstream: Subscriber>: NSObject, CXShim.Subscription where Downstream.Input == Output?, Downstream.Failure == Never {
        
        private let lock = NSLock()
        
        private let downstreamLock = NSRecursiveLock()
        
        private var downstream: Downstream?
        
        private var demand = Subscribers.Demand.none
        
        private var object: UserDefaults?
        
        private let key: DefaultsKey<Output>
        
        init(object: UserDefaults, key: DefaultsKey<Output>, downstream: Downstream) {
            self.object = object
            self.key = key
            self.downstream = downstream
            super.init()
            object.addObserver(self, forKeyPath: key.key, options: [.new], context: nil)
        }
        
        deinit {
            cancel()
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            self.demand += demand
            lock.unlock()
        }
        
        func cancel() {
            lock.lock()
            guard let object = self.object else {
                lock.unlock()
                return
            }
            self.object = nil
            lock.unlock()
            object.removeObserver(self, forKeyPath: key.key, context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            lock.lock()
            guard demand > 0, let downstream = downstream else {
                lock.unlock()
                return
            }
            demand -= 1
            lock.unlock()
            
            downstreamLock.lock()
            let value = self.object?[self.key]
            let newDemand = downstream.receive(value)
            downstreamLock.unlock()
            
            lock.lock()
            demand += newDemand
            lock.unlock()
        }
    }
    
    final class MultiValueSubscription<Downstream: Subscriber>: NSObject, CXShim.Subscription where Downstream.Input == Void, Downstream.Failure == Never {
        
        private let lock = NSLock()
        
        private let downstreamLock = NSRecursiveLock()
        
        private var downstream: Downstream?
        
        private var demand = Subscribers.Demand.none
        
        private var object: UserDefaults?
        
        private var keys: [DefaultsKeys]
        
        init(object: UserDefaults, keys: [DefaultsKeys], downstream: Downstream) {
            self.object = object
            self.keys = keys
            self.downstream = downstream
            super.init()
            for key in keys {
                object.addObserver(self, forKeyPath: key.key, options: [.new], context: nil)
            }
        }
        
        deinit {
            cancel()
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            self.demand += demand
            lock.unlock()
        }
        
        func cancel() {
            lock.lock()
            guard let object = self.object else {
                lock.unlock()
                return
            }
            self.object = nil
            lock.unlock()
            for key in keys {
                object.removeObserver(self, forKeyPath: key.key, context: nil)
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            lock.lock()
            guard demand > 0, let downstream = downstream else {
                lock.unlock()
                return
            }
            demand -= 1
            lock.unlock()
            
            downstreamLock.lock()
            let newDemand = downstream.receive()
            downstreamLock.unlock()
            
            lock.lock()
            demand += newDemand
            lock.unlock()
        }
    }
}

#endif // canImport(CXShim)
