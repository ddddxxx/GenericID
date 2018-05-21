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
    
    public final class DataCoderValueTransformer: ValueTransformer {
        
        let encoder: DataEncoder
        let decoder: DataDecoder
        
        init(encoder: DataEncoder, decoder: DataDecoder) {
            self.encoder = encoder
            self.decoder = decoder
        }
        
        public override func serialize<T>(_ value: T) -> Any? {
            guard let v = value as? Encodable else { return nil }
            return try? v.encodedData(encoder: encoder)
        }
        
        public override func deserialize<T>(_ type: T.Type, from: Any) -> T? {
            // Unwrap optional type. this can be removed with dynamically querying conditional conformance in Swift 4.2.
            let unwrappedType = unwrap(type)
            guard let t = unwrappedType as? Decodable.Type,
                let data = from as? Data else {
                    return nil
            }
            return (try? t.init(data: data, decoder: decoder)) as? T
        }
    }
    
    public final class KeyedArchiveValueTransformer: ValueTransformer {
        
        public override func serialize<T>(_ value: T) -> Any? {
            return NSKeyedArchiver.archivedData(withRootObject: value)
        }
        
        public override func deserialize<T>(_ type: T.Type, from: Any) -> T? {
            guard let data = from as? Data else { return nil }
            return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? T
        }
    }
}

extension UserDefaults.ValueTransformer {
    
    public static let json = UserDefaults.DataCoderValueTransformer(encoder: JSONEncoder(),
                                                                    decoder: JSONDecoder())
    
    public static let plist = UserDefaults.DataCoderValueTransformer(encoder: PropertyListEncoder(),
                                                                     decoder: PropertyListDecoder())
    
    public static let keyedArchive = UserDefaults.KeyedArchiveValueTransformer()
}

// MARK: -

extension NSKeyedUnarchiver {
    
    private class DummyKeyedUnarchiverDelegate: NSObject, NSKeyedUnarchiverDelegate {
        
        @objc(UnknownClass_AyWMH3gRIKYqLBV4)
        private final class Unknown: NSObject, NSCoding {
            func encode(with aCoder: NSCoder) {}
            init?(coder aDecoder: NSCoder) { return nil }
        }
        
        var unknownClassName: String?
        
        func unarchiver(_ unarchiver: NSKeyedUnarchiver, cannotDecodeObjectOfClassName name: String, originalClasses classNames: [String]) -> Swift.AnyClass? {
            unknownClassName = name
            print(classNames)
            return Unknown.self
        }
    }
    
    @available(macOS, obsoleted: 10.11)
    @available(iOS, obsoleted: 9.0)
    @nonobjc class func unarchiveTopLevelObjectWithData(_ data: Data) throws -> Any? {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        let delegate = DummyKeyedUnarchiverDelegate()
        unarchiver.delegate = delegate
        let obj = unarchiver.decodeObject(forKey: "root")
        if let name = delegate.unknownClassName {
            let desc = "*** -[NSKeyedUnarchiver decodeObjectForKey:]: cannot decode object of class (\(name)); the class may be defined in source code or a library that is not linked"
            throw NSError(domain: NSCocoaErrorDomain, code: 4864, userInfo: [NSDebugDescriptionErrorKey: desc])
        }
        return obj
    }
}
