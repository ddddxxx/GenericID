//
//  DefaultsKey.swift
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
    
    public typealias DefaultsKey<T> = DefaultsKeys.Key<T>
    
    public class DefaultsKeys {
        
        public let key: String
        
        public let valueTransformer: ValueTransformer?
        
        private init(_ key: String) {
            self.key = key
            self.valueTransformer = nil
        }
        
        private init(_ key: String, transformer: ValueTransformer) {
            self.key = key
            self.valueTransformer = transformer
        }
        
        func serialize(_ v: Any) -> Any? {
            fatalError("Must override")
        }
        
        func deserialize(_ v: Any) -> Any? {
            fatalError("Must override")
        }
    }
}

extension UserDefaults.DefaultsKeys {
    
    public final class Key<T>: UserDefaults.DefaultsKeys {
        
        public override init(_ key: String) {
            super.init(key)
        }
        
        public override init(_ key: String, transformer: UserDefaults.ValueTransformer) {
            super.init(key, transformer: transformer)
        }
        
        override func serialize(_ v: Any) -> Any? {
            guard let t = valueTransformer else { return v }
            return t.serialize(v)
        }
        
        override func deserialize(_ v: Any) -> Any? {
            guard let t = valueTransformer else { return v }
            return t.deserialize(T.self, from: v)
        }
        
        func deserialize(_ v: Any) -> T? {
            guard let t = valueTransformer else { return v as? T }
            return t.deserialize(T.self, from: v)
        }
    }
}

// MARK: - Conformances

extension UserDefaults.DefaultsKeys: Equatable {
    
    public static func ==(lhs: UserDefaults.DefaultsKeys, rhs: UserDefaults.DefaultsKeys) -> Bool {
        guard lhs.key == rhs.key else { return false }
        switch (lhs.valueTransformer, rhs.valueTransformer) {
        case (nil, nil):            return true
        case (_, nil), (nil, _):    return false
        case let (l, r):            return type(of: l) == type(of: r)
        }
    }
}

extension UserDefaults.DefaultsKeys: Hashable {
    
    public var hashValue: Int {
        return key.hashValue
    }
}

extension UserDefaults.DefaultsKeys.Key: ExpressibleByStringLiteral {
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
