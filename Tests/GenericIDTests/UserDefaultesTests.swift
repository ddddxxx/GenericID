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
    
    func testOptString() {
        XCTAssertNil(defaults[.StringOptKey])
        
        defaults[.StringOptKey] = "foo"
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        
        defaults[.StringOptKey]?.append("bar")
        XCTAssertEqual(defaults[.StringOptKey], "foobar")
    }
    
    func testOptURL() {
        XCTAssertNil(defaults[.URLOptKey])
        
        let url = URL(string: "https://google.com")
        defaults[.URLOptKey] = url
        XCTAssertEqual(defaults[.URLOptKey], url)
        
        defaults[.URLOptKey]?.appendPathComponent("404")
        XCTAssertEqual(defaults[.URLOptKey], URL(string: "https://google.com/404")!)
    }
    
    func testOptDate() {
        XCTAssertNil(defaults[.DateOptKey])
        
        let date = Date()
        defaults[.DateOptKey] = date
        XCTAssertEqual(defaults[.DateOptKey], date)
        
        defaults[.DateOptKey]?.addTimeInterval(123)
        XCTAssertEqual(defaults[.DateOptKey], date.addingTimeInterval(123))
    }
    
    func testOptData() {
        XCTAssertNil(defaults[.DataOptKey])
        
        let data = "foo".data(using: .ascii)!
        defaults[.DataOptKey] = data
        XCTAssertEqual(defaults[.DataOptKey], data)
        
        defaults[.DataOptKey]?.removeFirst()
        XCTAssertEqual(defaults[.DataOptKey], Data(data.dropFirst()))
    }
    
    func testOptArray() {
        XCTAssertNil(defaults[.ArrayOptKey])
        
        defaults[.ArrayOptKey] = [true, 233, 3.14]
        XCTAssertEqual(defaults[.ArrayOptKey]?[0] as? Bool,   true)
        XCTAssertEqual(defaults[.ArrayOptKey]?[1] as? Int,    233)
        XCTAssertEqual(defaults[.ArrayOptKey]?[2] as? Double, 3.14)
        
        defaults[.ArrayOptKey]?.append("foo")
        XCTAssertEqual(defaults[.ArrayOptKey]?[3] as? String, "foo")
    }
    
    func testOptStringArray() {
        XCTAssertNil(defaults[.StringArrayOptKey])
        
        defaults[.StringArrayOptKey] = ["foo", "bar", "baz"]
        XCTAssertEqual(defaults[.StringArrayOptKey]?[0], "foo")
        XCTAssertEqual(defaults[.StringArrayOptKey]?[1], "bar")
        XCTAssertEqual(defaults[.StringArrayOptKey]?[2], "baz")
        
        defaults[.StringArrayOptKey]?.append("qux")
        XCTAssertEqual(defaults[.StringArrayOptKey]?[3], "qux")
    }
    
    func testOptDictionary() {
        XCTAssertNil(defaults[.DictionaryOptKey])
        
        defaults[.DictionaryOptKey] = [
            "foo": true,
            "bar": 233,
            "baz": 3.14,
        ]
        XCTAssertEqual(defaults[.DictionaryOptKey]?["foo"] as? Bool, true)
        XCTAssertEqual(defaults[.DictionaryOptKey]?["bar"] as? Int, 233)
        XCTAssertEqual(defaults[.DictionaryOptKey]?["baz"] as? Double, 3.14)
        
        defaults[.DictionaryOptKey]?["qux"] = [1, 2, 3]
        XCTAssertEqual(defaults[.DictionaryOptKey]?["qux"] as! [Int], [1, 2, 3])
    }
    
    func testOptAny() {
        XCTAssertNil(defaults[.AnyOptKey])
        
        defaults[.AnyOptKey] = true
        XCTAssertEqual(defaults[.AnyOptKey] as? Bool, true)
        
        defaults[.AnyOptKey] = 233
        XCTAssertEqual(defaults[.AnyOptKey] as? Int, 233)
        
        defaults[.AnyOptKey] = 3.14
        XCTAssertEqual(defaults[.AnyOptKey] as? Double, 3.14)
        
        defaults[.AnyOptKey] = "foo"
        XCTAssertEqual(defaults[.AnyOptKey] as? String, "foo")
        
        defaults[.AnyOptKey] = [1, 2, 3]
        XCTAssertEqual(defaults[.AnyOptKey] as! [Int], [1, 2, 3])
    }
    
    // MARK: - Other Key
    
    func testArchiving() {
        XCTAssertNil(defaults.unarchive(.ColorOptKey))
        
        var color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        defaults.archive(color, for: .ColorOptKey)
        XCTAssertEqual(defaults.unarchive(.ColorOptKey), color)
        
        color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        defaults.archive(color, for: .ColorOptKey)
        XCTAssertEqual(defaults.unarchive(.ColorOptKey), color)
    }
    
    func testWrapping() {
        XCTAssertNil(defaults.unwrap(.RectOptKey))
        
        var rect = CGRect(x: 1, y: 2, width: 3, height: 4)
        defaults.wrap(rect, for: .RectOptKey)
        XCTAssertEqual(defaults.unwrap(.RectOptKey), rect)
        
        rect = CGRect(x: 5, y: 6, width: 7, height: 8)
        defaults.wrap(rect, for: .RectOptKey)
        XCTAssertEqual(defaults.unwrap(.RectOptKey), rect)
    }
    
    func testRemoving() {
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertNil(defaults[.StringOptKey])
        
        defaults[.StringOptKey] = "foo"
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        
        XCTAssertTrue(defaults.contains(.StringOptKey))
        XCTAssertNotNil(defaults[.StringOptKey])
        
        defaults.remove(.StringOptKey)
        
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertNil(defaults[.StringOptKey])
    }
    
    // MARK: -
    
    func testRegistration() {
        XCTAssertEqual(defaults[.IntKey], 0)
        XCTAssertNil(defaults[.StringOptKey])
        XCTAssertNil(defaults.unarchive(.ColorOptKey))
        XCTAssertNil(defaults.unwrap(.RectOptKey))
        
        let dict: [UserDefaults.DefaultKeys : Any] = [
            .IntKey: 42,
            .StringOptKey: "foo",
            .ColorOptKey: NSColor.red,
            .RectOptKey: CGRect.infinite
        ]
        defaults.register(defaults: dict)
        
        XCTAssertEqual(defaults[.IntKey], 42)
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        XCTAssertEqual(defaults.unarchive(.ColorOptKey), .red)
        XCTAssertEqual(defaults.unwrap(.RectOptKey), .infinite)
        
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
        defaults.archive(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .ColorOptKey)
        let token = defaults.addObserver(key: .ColorOptKey) { oldValue, newValue in
            XCTAssertEqual(oldValue, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            XCTAssertEqual(newValue, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            exec = true
        }
        defaults.archive(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .ColorOptKey)
        XCTAssert(exec)
        
        exec = false
        token.invalidate()
        defaults.archive(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .ColorOptKey)
        XCTAssertFalse(exec)
    }
    
}
