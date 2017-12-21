//
//  TestKeys.swift
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

#if os(macOS)
    import Cocoa
    typealias Color = NSColor
#else
    import UIKit
    typealias Color = UIColor
#endif

extension UserDefaults.DefaultKeys {
    static let BoolKey      = Key<Bool>("BoolKey")
    static let IntKey       = Key<Int>("IntKey")
    static let FloatKey     = Key<Float>("FloatKey")
    static let DoubleKey    = Key<Double>("DoubleKey")
    static let StringKey    = Key<String>("StringKey")
    static let DataKey      = Key<Data>("DataKey")
    static let ArrayKey     = Key<[Any]>("ArrayKey")
    static let StringArrayKey   = Key<[String]>("StringArrayKey")
    static let DictionaryKey    = Key<[String: Any]>("DictionaryKey")
}

extension UserDefaults.DefaultKeys {
    static let BoolOptKey       = Key<Bool?>("BoolOptKey")
    static let IntOptKey        = Key<Int?>("IntOptKey")
    static let FloatOptKey      = Key<Float?>("FloatOptKey")
    static let DoubleOptKey     = Key<Double?>("DoubleOptKey")
    static let StringOptKey     = Key<String?>("StringOptKey")
    static let URLOptKey        = Key<URL?>("URLOptKey", transformer: .keyedArchive)
    static let DateOptKey       = Key<Date?>("DateOptKey")
    static let DataOptKey       = Key<Data?>("DataOptKey")
    static let ArrayOptKey      = Key<[Any]?>("ArrayOptKey")
    static let StringArrayOptKey = Key<[String]?>("StringArrayOptKey")
    static let DictionaryOptKey = Key<[String: Any]?>("DictionaryOptKey")
    static let ColorOptKey      = Key<Color>("ColorOptKey", transformer: .keyedArchive)
    static let RectOptKey       = Key<CGRect>("RectOptKey", transformer: .json)
    static let AnyOptKey        = Key<Any>("AnyOptKey")
}

extension NSObject.AssociateKeys {
    static let ValueTypeKey: Key<Int>           = "ValueTypeKey"
    static let ReferenceTypeKey: Key<NSDate>    = "ReferenceTypeKey"
}
