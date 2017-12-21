//
//  DefaultsValueTransformer.swift
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
    
    public class ValueTransformer {
        
        public func serialize<T>(_ value: T) -> Data? {
            fatalError("Must override")
        }
        
        public func deserialize<T>(_ value: Data) -> T? {
            fatalError("Must override")
        }
    }
    
    public class JSONValueTransformer: ValueTransformer {
        
        public override func serialize<T>(_ value: T) -> Data? {
            guard let v = value as? Encodable else { return nil }
            return v.codedData
        }
        
        public override func deserialize<T>(_ value: Data) -> T? {
            guard let t = T.self as? Decodable.Type else { return nil }
            return t.init(codedData: value) as? T
        }
    }
    
    public class KeyedArchiveValueTransformer: ValueTransformer {
        
        public override func serialize<T>(_ value: T) -> Data? {
            return NSKeyedArchiver.archivedData(withRootObject: value)
        }
        
        public override func deserialize<T>(_ value: Data) -> T? {
            return NSKeyedUnarchiver.unarchiveObjectWithoutException(with: value) as? T
        }
    }
    
    #if os(macOS)
        
        public class ArchiveValueTransformer: ValueTransformer {
            
            public override func serialize<T>(_ value: T) -> Data? {
                return NSArchiver.archivedData(withRootObject: value)
            }
            
            public override func deserialize<T>(_ value: Data) -> T? {
                return NSUnarchiver.unarchiveObjectWithoutException(with: value) as? T
            }
        }
    
    #endif
}

extension UserDefaults.ValueTransformer {
    
    public static let json = UserDefaults.JSONValueTransformer()
    
    public static let keyedArchive = UserDefaults.KeyedArchiveValueTransformer()
    
    #if os(macOS)
    
        public static let archive = UserDefaults.ArchiveValueTransformer()
    
    #endif
}

extension Encodable {
    
    var codedData: Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Decodable {
    
    init?(codedData: Data) {
        guard let v = try? JSONDecoder().decode(Self.self, from: codedData) else { return nil }
        self = v
    }
}
