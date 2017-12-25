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
    
    open class ValueTransformer {
        
        open func serialize<T>(_ value: T) -> Any? {
            fatalError("Must override")
        }
        
        open func deserialize<T>(_ type: T.Type, from: Any) -> T? {
            fatalError("Must override")
        }
    }
    
    public final class JSONValueTransformer: ValueTransformer {
        
        public override func serialize<T>(_ value: T) -> Any? {
            guard let v = value as? Encodable else { return nil }
            return v.jsonData
        }
        
        public override func deserialize<T>(_ type: T.Type, from: Any) -> T? {
            guard let t = T.self as? Decodable.Type,
                let data = from as? Data else {
                    return nil
            }
            return t.init(jsonData: data) as? T
        }
    }
    
    public final class PropertyListValueTransformer: ValueTransformer {
        
        public override func serialize<T>(_ value: T) -> Any? {
            guard let v = value as? Encodable else { return nil }
            return v.plistData
        }
        
        public override func deserialize<T>(_ type: T.Type, from: Any) -> T? {
            guard let t = T.self as? Decodable.Type,
                let data = from as? Data else {
                    return nil
            }
            return t.init(plistData: data) as? T
        }
    }
    
    public final class KeyedArchiveValueTransformer: ValueTransformer {
        
        public override func serialize<T>(_ value: T) -> Any? {
            return NSKeyedArchiver.archivedData(withRootObject: value)
        }
        
        public override func deserialize<T>(_ type: T.Type, from: Any) -> T? {
            guard let data = from as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObjectWithoutException(with: data) as? T
        }
    }
    
    #if os(macOS)
        
        public final class ArchiveValueTransformer: ValueTransformer {
            
            public override func serialize<T>(_ value: T) -> Any? {
                return NSArchiver.archivedData(withRootObject: value)
            }
            
            public override func deserialize<T>(_ type: T.Type, from: Any) -> T? {
                guard let data = from as? Data else { return nil }
                return NSUnarchiver.unarchiveObjectWithoutException(with: data) as? T
            }
        }
    
    #endif
}

extension UserDefaults.ValueTransformer {
    
    public static let json = UserDefaults.JSONValueTransformer()
    
    public static let plist = UserDefaults.PropertyListValueTransformer()
    
    public static let keyedArchive = UserDefaults.KeyedArchiveValueTransformer()
    
    #if os(macOS)
    
        public static let archive = UserDefaults.ArchiveValueTransformer()
    
    #endif
}

// MARK: - Codable

fileprivate extension Encodable {
    
    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var plistData: Data? {
        return try? PropertyListEncoder().encode(self)
    }
}

fileprivate extension Decodable {
    
    init?(jsonData: Data) {
        guard let v = try? JSONDecoder().decode(Self.self, from: jsonData) else { return nil }
        self = v
    }
    
    init?(plistData: Data) {
        guard let v = try? PropertyListDecoder().decode(Self.self, from: plistData) else { return nil }
        self = v
    }
}
