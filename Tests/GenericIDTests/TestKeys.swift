//
//  TestKeys.swift
//  GenericID
//
//  Created by 邓翔 on 2017/8/24.
//
//

#if os(macOS)
    import Cocoa
    typealias Color = NSColor
#else
    import UIKit
    typealias Color = UIColor
#endif

extension UserDefaults.DefaultKeys {
    static let BoolKey: Key<Bool>                   = "BoolKey"
    static let IntKey: Key<Int>                     = "IntKey"
    static let FloatKey: Key<Float>                 = "FloatKey"
    static let DoubleKey: Key<Double>               = "DoubleKey"
    static let StringKey: Key<String>               = "StringKey"
    static let ArrayKey: Key<[Any]>                = "ArrayKey"
    static let StringArrayKey: Key<[String]>       = "StringArrayKey"
    static let DictionaryKey: Key<[String: Any]>   = "DictionaryKey"
}

extension UserDefaults.DefaultKeys {
    static let BoolOptKey: Key<Bool?>                = "BoolOptKey"
    static let IntOptKey: Key<Int?>                  = "IntOptKey"
    static let FloatOptKey: Key<Float?>              = "FloatOptKey"
    static let DoubleOptKey: Key<Double?>            = "DoubleOptKey"
    static let StringOptKey: Key<String?>           = "StringOptKey"
    static let URLOptKey: Key<URL?>                 = "URLOptKey"
    static let DateOptKey: Key<Date?>               = "DateOptKey"
    static let DataOptKey: Key<Data?>               = "DataOptKey"
    static let ArrayOptKey: Key<[Any]?>             = "ArrayOptKey"
    static let StringArrayOptKey: Key<[String]?>    = "StringArrayOptKey"
    static let DictionaryOptKey: Key<[String: Any]?> = "DictionaryOptKey"
    static let ColorOptKey: Key<Color?>             = "ColorOptKey"
    static let RectOptKey: Key<CGRect?>             = "RectOptKey"
    static let AnyOptKey: Key<Any?>                 = "AnyOptKey"
}

extension NSObject.AssociateKeys {
    static let ValueTypeKey: Key<Int>           = "ValueTypeKey"
    static let ReferenceTypeKey: Key<NSDate>    = "ReferenceTypeKey"
}
