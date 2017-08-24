//
//  UserDefaultesTests.swift
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

import XCTest
@testable import GenericID

#if os(macOS)
    import Cocoa
    typealias Color = NSColor
#else
    import UIKit
    typealias Color = UIColor
#endif

class UserDefaultesTests: XCTestCase {
    
    let defaults = UserDefaults.standard
    
    override func setUp() {
        defaults.unregisterAll()
        defaults.removeAll()
    }
    
    // MARK: - Non-Optional Key
    
    func testBool() {
        XCTAssertEqual(defaults[.BoolKey], false)
        
        defaults[.BoolKey] = true
        XCTAssertEqual(defaults[.BoolKey], true)
    }
    
    func testInt() {
        XCTAssertEqual(defaults[.IntKey], 0)
        
        defaults[.IntKey] = 233
        XCTAssertEqual(defaults[.IntKey], 233)
        
        defaults[.IntKey] += 233
        XCTAssertEqual(defaults[.IntKey], 466)
    }
    
    func testFloat() {
        XCTAssertEqual(defaults[.FloatKey], 0)
        
        defaults[.FloatKey] = 3.14
        XCTAssertEqual(defaults[.FloatKey], 3.14)
        
        defaults[.FloatKey] += 0.01
        XCTAssertEqual(defaults[.FloatKey], 3.15)
    }
    
    func testDouble() {
        XCTAssertEqual(defaults[.DoubleKey], 0)
        
        defaults[.DoubleKey] = 3.14
        XCTAssertEqual(defaults[.DoubleKey], 3.14)
        
        defaults[.DoubleKey] += 0.01
        XCTAssertEqual(defaults[.DoubleKey], 3.15)
    }
    
    // MARK: - Optional Key
    
    func testString() {
        XCTAssertNil(defaults[.StringKey])
        
        defaults[.StringKey] = "foo"
        XCTAssertEqual(defaults[.StringKey], "foo")
        
        defaults[.StringKey]?.append("bar")
        XCTAssertEqual(defaults[.StringKey], "foobar")
    }
    
    func testURL() {
        XCTAssertNil(defaults[.URLKey])
        
        let url = URL(string: "https://google.com")
        defaults[.URLKey] = url
        XCTAssertEqual(defaults[.URLKey], url)
        
        defaults[.URLKey]?.appendPathComponent("404")
        XCTAssertEqual(defaults[.URLKey], URL(string: "https://google.com/404")!)
    }
    
    func testDate() {
        XCTAssertNil(defaults[.DateKey])
        
        let date = Date()
        defaults[.DateKey] = date
        XCTAssertEqual(defaults[.DateKey], date)
        
        defaults[.DateKey]?.addTimeInterval(123)
        XCTAssertEqual(defaults[.DateKey], date.addingTimeInterval(123))
    }
    
    func testData() {
        XCTAssertNil(defaults[.DataKey])
        
        let data = "foo".data(using: .ascii)!
        defaults[.DataKey] = data
        XCTAssertEqual(defaults[.DataKey], data)
        
        defaults[.DataKey]?.removeFirst()
        XCTAssertEqual(defaults[.DataKey], Data(data.dropFirst()))
    }
    
    func testArray() {
        XCTAssertNil(defaults[.ArrayKey])
        
        defaults[.ArrayKey] = [true, 233, 3.14]
        XCTAssertEqual(defaults[.ArrayKey]?[0] as? Bool,   true)
        XCTAssertEqual(defaults[.ArrayKey]?[1] as? Int,    233)
        XCTAssertEqual(defaults[.ArrayKey]?[2] as? Double, 3.14)
        
        defaults[.ArrayKey]?.append("foo")
        XCTAssertEqual(defaults[.ArrayKey]?[3] as? String, "foo")
    }
    
    func testStringArray() {
        XCTAssertNil(defaults[.StringArrayKey])
        
        defaults[.StringArrayKey] = ["foo", "bar", "baz"]
        XCTAssertEqual(defaults[.StringArrayKey]?[0], "foo")
        XCTAssertEqual(defaults[.StringArrayKey]?[1], "bar")
        XCTAssertEqual(defaults[.StringArrayKey]?[2], "baz")
        
        defaults[.StringArrayKey]?.append("qux")
        XCTAssertEqual(defaults[.StringArrayKey]?[3], "qux")
    }
    
    func testDictionary() {
        XCTAssertNil(defaults[.DictionaryKey])
        
        defaults[.DictionaryKey] = [
            "foo": true,
            "bar": 233,
            "baz": 3.14,
        ]
        XCTAssertEqual(defaults[.DictionaryKey]?["foo"] as? Bool, true)
        XCTAssertEqual(defaults[.DictionaryKey]?["bar"] as? Int, 233)
        XCTAssertEqual(defaults[.DictionaryKey]?["baz"] as? Double, 3.14)
        
        defaults[.DictionaryKey]?["qux"] = [1, 2, 3]
        XCTAssertEqual(defaults[.DictionaryKey]?["qux"] as! [Int], [1, 2, 3])
    }
    
    func testAny() {
        XCTAssertNil(defaults[.AnyKey])
        
        defaults[.AnyKey] = true
        XCTAssertEqual(defaults[.AnyKey] as? Bool, true)
        
        defaults[.AnyKey] = 233
        XCTAssertEqual(defaults[.AnyKey] as? Int, 233)
        
        defaults[.AnyKey] = 3.14
        XCTAssertEqual(defaults[.AnyKey] as? Double, 3.14)
        
        defaults[.AnyKey] = "foo"
        XCTAssertEqual(defaults[.AnyKey] as? String, "foo")
        
        defaults[.AnyKey] = [1, 2, 3]
        XCTAssertEqual(defaults[.AnyKey] as! [Int], [1, 2, 3])
    }
    
    // MARK: -
    
    func testArchiving() {
        XCTAssertNil(defaults.unarchive(.ColorKey))
        
        var color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        defaults.archive(color, for: .ColorKey)
        XCTAssertEqual(defaults.unarchive(.ColorKey), color)
        
        color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        defaults.archive(color, for: .ColorKey)
        XCTAssertEqual(defaults.unarchive(.ColorKey), color)
    }
    
    func testWrapping() {
        XCTAssertNil(defaults.unwrap(.RectKey))
        
        var rect = CGRect(x: 1, y: 2, width: 3, height: 4)
        defaults.wrap(rect, for: .RectKey)
        XCTAssertEqual(defaults.unwrap(.RectKey), rect)
        
        rect = CGRect(x: 5, y: 6, width: 7, height: 8)
        defaults.wrap(rect, for: .RectKey)
        XCTAssertEqual(defaults.unwrap(.RectKey), rect)
    }
    
    func testRemoving() {
        XCTAssertFalse(defaults.contains(.StringKey))
        XCTAssertNil(defaults[.StringKey])
        
        defaults[.StringKey] = "foo"
        XCTAssertEqual(defaults[.StringKey], "foo")
        
        XCTAssertTrue(defaults.contains(.StringKey))
        XCTAssertNotNil(defaults[.StringKey])
        
        defaults.remove(.StringKey)
        
        XCTAssertFalse(defaults.contains(.StringKey))
        XCTAssertNil(defaults[.StringKey])
    }
    
    func testRegistration() {
        XCTAssertEqual(defaults[.IntKey], 0)
        XCTAssertNil(defaults[.StringKey])
        XCTAssertNil(defaults.unarchive(.ColorKey))
        XCTAssertNil(defaults.unwrap(.RectKey))
        
        let dict: [UserDefaults.DefaultKeys : Any] = [
            .IntKey: 42,
            .StringKey: "foo",
            .ColorKey: NSColor.red,
            .RectKey: CGRect.infinite
        ]
        defaults.register(defaults: dict)
        
        XCTAssertEqual(defaults[.IntKey], 42)
        XCTAssertEqual(defaults[.StringKey], "foo")
        XCTAssertEqual(defaults.unarchive(.ColorKey), .red)
        XCTAssertEqual(defaults.unwrap(.RectKey), .infinite)
        
        defaults.unregisterAll()
    }
    
    func testKVO() {
        var exec = false
        defaults[.IntKey] = 233
        let token = defaults.addObserver(key: .IntKey) { oldValue, newValue in
            XCTAssertEqual(oldValue, 233)
            XCTAssertEqual(newValue, 234)
            exec = true
        }
        defaults[.IntKey] += 1
        XCTAssert(exec)
        
        exec = false
        token.invalidate()
        defaults[.IntKey] = 123
        XCTAssertFalse(exec)
    }
    
    func testKVOWithCoding() {
        var exec = false
        defaults.archive(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .ColorKey)
        let token = defaults.addObserver(key: .ColorKey) { oldValue, newValue in
            XCTAssertEqual(oldValue, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            XCTAssertEqual(newValue, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            exec = true
        }
        defaults.archive(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .ColorKey)
        XCTAssert(exec)
        
        exec = false
        token.invalidate()
        defaults.archive(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .ColorKey)
        XCTAssertFalse(exec)
    }
    
}

// MARK: - Keys

extension UserDefaults.DefaultKeys {
    static let BoolKey: Key<Bool> = "BoolKey"
    static let IntKey: Key<Int> = "IntKey"
    static let FloatKey: Key<Float> = "FloatKey"
    static let DoubleKey: Key<Double> = "DoubleKey"
}

extension UserDefaults.DefaultKeys {
    static let StringKey: Key<String?> = "StringKey"
    static let URLKey: Key<URL?> = "URLKey"
    static let DateKey: Key<Date?> = "DateKey"
    static let DataKey: Key<Data?> = "DataKey"
    static let ArrayKey: Key<[Any]?> = "ArrayKey"
    static let StringArrayKey: Key<[String]?> = "StringArrayKey"
    static let DictionaryKey: Key<[String: Any]?> = "DictionaryKey"
    static let ColorKey: Key<Color?> = "ColorKey"
    static let RectKey: Key<CGRect?> = "RectKey"
    static let AnyKey: Key<Any?> = "AnyKey"
}
