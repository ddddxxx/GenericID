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
        super.setUp()
        defaults.unregisterAll()
        defaults.removeAll()
    }
    
    // MARK: - Non-Optional Key
    
    func testBool() {
        XCTAssertFalse(defaults[.BoolKey])
        
        defaults[.BoolKey] = true
        XCTAssertTrue(defaults[.BoolKey])
        
        defaults.remove(.BoolKey)
        XCTAssertFalse(defaults[.BoolKey])
    }
    
    func testInt() {
        XCTAssertEqual(defaults[.IntKey], 0)
        
        defaults[.IntKey] = 233
        XCTAssertEqual(defaults[.IntKey], 233)
        
        defaults[.IntKey] += 233
        XCTAssertEqual(defaults[.IntKey], 466)
        
        defaults.remove(.IntKey)
        XCTAssertEqual(defaults[.IntKey], 0)
    }
    
    func testFloat() {
        XCTAssertEqual(defaults[.FloatKey], 0)
        
        defaults[.FloatKey] = 3.14
        XCTAssertEqual(defaults[.FloatKey], 3.14)
        
        defaults[.FloatKey] += 0.01
        XCTAssertEqual(defaults[.FloatKey], 3.15)
        
        defaults.remove(.FloatKey)
        XCTAssertEqual(defaults[.FloatKey], 0)
    }
    
    func testDouble() {
        XCTAssertEqual(defaults[.DoubleKey], 0)
        
        defaults[.DoubleKey] = 3.14
        XCTAssertEqual(defaults[.DoubleKey], 3.14)
        
        defaults[.DoubleKey] += 0.01
        XCTAssertEqual(defaults[.DoubleKey], 3.15)
        
        defaults.remove(.DoubleKey)
        XCTAssertEqual(defaults[.DoubleKey], 0)
    }
    
    func testData() {
        XCTAssert(defaults[.DataKey].isEmpty)
        
        let data = "foo".data(using: .ascii)!
        defaults[.DataKey] = data
        XCTAssertEqual(defaults[.DataKey], data)
        
        defaults[.DataKey].removeFirst()
        XCTAssertEqual(defaults[.DataKey], Data(data.dropFirst()))
        
        defaults.remove(.DataKey)
        XCTAssert(defaults[.DataKey].isEmpty)
    }
    
    func testString() {
        XCTAssert(defaults[.StringKey].isEmpty)
        
        defaults[.StringKey] = "foo"
        XCTAssertEqual(defaults[.StringKey], "foo")
        
        defaults[.StringKey] += "bar"
        XCTAssertEqual(defaults[.StringKey], "foobar")
        
        defaults.remove(.StringKey)
        XCTAssert(defaults[.StringKey].isEmpty)
    }
    
    func testArray() {
        XCTAssert(defaults[.ArrayKey].isEmpty)
        
        defaults[.ArrayKey] = [true, 233, 3.14]
        XCTAssertEqual(defaults[.ArrayKey].count, 3)
        XCTAssertEqual(defaults[.ArrayKey][0] as? Bool,   true)
        XCTAssertEqual(defaults[.ArrayKey][1] as? Int,    233)
        XCTAssertEqual(defaults[.ArrayKey][2] as? Double, 3.14)
        
        defaults[.ArrayKey].append("foo")
        XCTAssertEqual(defaults[.ArrayKey].count, 4)
        XCTAssertEqual(defaults[.ArrayKey][3] as? String, "foo")
        
        defaults.remove(.ArrayKey)
        XCTAssert(defaults[.ArrayKey].isEmpty)
    }
    
    func testStringArray() {
        XCTAssert(defaults[.StringArrayKey].isEmpty)
        
        defaults[.StringArrayKey] = ["foo", "bar", "baz"]
        XCTAssertEqual(defaults[.StringArrayKey][0], "foo")
        XCTAssertEqual(defaults[.StringArrayKey][1], "bar")
        XCTAssertEqual(defaults[.StringArrayKey][2], "baz")
        
        defaults[.StringArrayKey].append("qux")
        XCTAssertEqual(defaults[.StringArrayKey][3], "qux")
        
        defaults.remove(.StringArrayKey)
        XCTAssert(defaults[.StringArrayKey].isEmpty)
    }
    
    func testDictionary() {
        XCTAssert(defaults[.DictionaryKey].isEmpty)
        
        defaults[.DictionaryKey] = [
            "foo": true,
            "bar": 233,
            "baz": 3.14,
        ]
        XCTAssertEqual(defaults[.DictionaryKey]["foo"] as? Bool, true)
        XCTAssertEqual(defaults[.DictionaryKey]["bar"] as? Int, 233)
        XCTAssertEqual(defaults[.DictionaryKey]["baz"] as? Double, 3.14)
        
        defaults[.DictionaryKey]["qux"] = [1, 2, 3]
        XCTAssertEqual(defaults[.DictionaryKey]["qux"] as! [Int], [1, 2, 3])
        
        defaults.remove(.DictionaryKey)
        XCTAssert(defaults[.DictionaryKey].isEmpty)
    }
    
    // MARK: - Optional Key
    
    func testOptBool() {
        XCTAssertNil(defaults[.BoolOptKey])
        
        defaults[.BoolOptKey] = true
        XCTAssertEqual(defaults[.BoolOptKey], true)
        
        defaults[.BoolOptKey] = nil
        XCTAssertNil(defaults[.BoolOptKey])
    }
    
    func testOptInt() {
        XCTAssertNil(defaults[.IntOptKey])
        
        defaults[.IntOptKey] = 233
        XCTAssertEqual(defaults[.IntOptKey], 233)
        
        defaults[.IntOptKey]? += 233
        XCTAssertEqual(defaults[.IntOptKey], 466)
        
        defaults[.IntOptKey] = nil
        XCTAssertNil(defaults[.IntOptKey])
    }
    
    func testOptFloat() {
        XCTAssertNil(defaults[.FloatOptKey])
        
        defaults[.FloatOptKey] = 3.14
        XCTAssertEqual(defaults[.FloatOptKey], 3.14)
        
        defaults[.FloatOptKey]? += 0.01
        XCTAssertEqual(defaults[.FloatOptKey], 3.15)
        
        defaults[.FloatOptKey] = nil
        XCTAssertNil(defaults[.FloatOptKey])
    }
    
    func testOptDouble() {
        XCTAssertNil(defaults[.DoubleOptKey])
        
        defaults[.DoubleOptKey] = 3.14
        XCTAssertEqual(defaults[.DoubleOptKey], 3.14)
        
        defaults[.DoubleOptKey]? += 0.01
        XCTAssertEqual(defaults[.DoubleOptKey], 3.15)
        
        defaults[.DoubleOptKey] = nil
        XCTAssertNil(defaults[.DoubleOptKey])
    }
    
    func testOptString() {
        XCTAssertNil(defaults[.StringOptKey])
        
        defaults[.StringOptKey] = "foo"
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        
        defaults[.StringOptKey]? += "bar"
        XCTAssertEqual(defaults[.StringOptKey], "foobar")
        
        defaults[.StringOptKey] = nil
        XCTAssertNil(defaults[.StringOptKey])
    }
    
    func testOptURL() {
        XCTAssertNil(defaults[.URLOptKey])
        
        let url = URL(string: "https://google.com")!
        defaults[.URLOptKey] = url
        XCTAssertEqual(defaults[.URLOptKey], url)
        
        defaults[.URLOptKey]?.appendPathComponent("404")
        XCTAssertEqual(defaults[.URLOptKey], URL(string: "https://google.com/404")!)
        
        defaults[.URLOptKey] = nil
        XCTAssertNil(defaults[.URLOptKey])
    }
    
    func testOptDate() {
        XCTAssertNil(defaults[.DateOptKey])
        
        let date = Date()
        defaults[.DateOptKey] = date
        XCTAssertEqual(defaults[.DateOptKey], date)
        
        defaults[.DateOptKey]?.addTimeInterval(123)
        XCTAssertEqual(defaults[.DateOptKey], date.addingTimeInterval(123))
        
        defaults[.DateOptKey] = nil
        XCTAssertNil(defaults[.DateOptKey])
    }
    
    func testOptData() {
        XCTAssertNil(defaults[.DataOptKey])
        
        let data = "foo".data(using: .ascii)!
        defaults[.DataOptKey] = data
        XCTAssertEqual(defaults[.DataOptKey], data)
        
        defaults[.DataOptKey]?.removeFirst()
        XCTAssertEqual(defaults[.DataOptKey], Data(data.dropFirst()))
        
        defaults[.DataOptKey] = nil
        XCTAssertNil(defaults[.DataOptKey])
    }
    
    func testOptArray() {
        XCTAssertNil(defaults[.ArrayOptKey])
        
        defaults[.ArrayOptKey] = [true, 233, 3.14]
        XCTAssertEqual(defaults[.ArrayOptKey]?[0] as? Bool,   true)
        XCTAssertEqual(defaults[.ArrayOptKey]?[1] as? Int,    233)
        XCTAssertEqual(defaults[.ArrayOptKey]?[2] as? Double, 3.14)
        
        defaults[.ArrayOptKey]?.append("foo")
        XCTAssertEqual(defaults[.ArrayOptKey]?[3] as? String, "foo")
        
        defaults[.ArrayOptKey] = nil
        XCTAssertNil(defaults[.ArrayOptKey])
    }
    
    func testOptStringArray() {
        XCTAssertNil(defaults[.StringArrayOptKey])
        
        defaults[.StringArrayOptKey] = ["foo", "bar", "baz"]
        XCTAssertEqual(defaults[.StringArrayOptKey]?[0], "foo")
        XCTAssertEqual(defaults[.StringArrayOptKey]?[1], "bar")
        XCTAssertEqual(defaults[.StringArrayOptKey]?[2], "baz")
        
        defaults[.StringArrayOptKey]?.append("qux")
        XCTAssertEqual(defaults[.StringArrayOptKey]?[3], "qux")
        
        defaults[.StringArrayOptKey] = nil
        XCTAssertNil(defaults[.StringArrayOptKey])
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
        
        defaults[.DictionaryOptKey] = nil
        XCTAssertNil(defaults[.DictionaryOptKey])
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
        
        defaults[.AnyOptKey] = nil
        XCTAssertNil(defaults[.AnyOptKey])
    }
    
    // MARK: - Other Key
    
    func testArchiving() {
        XCTAssertNil(defaults[.ColorOptKey])
        
        defaults[.ColorOptKey] = .red
        XCTAssertEqual(defaults[.ColorOptKey], .red)
        
        defaults[.ColorOptKey] = .green
        XCTAssertEqual(defaults[.ColorOptKey], .green)
    }
    
    func testCoding() {
        XCTAssertNil(defaults[.RectOptKey])
        
        var rect = CGRect(x: 1, y: 2, width: 3, height: 4)
        defaults[.RectOptKey] = rect
        XCTAssertEqual(defaults[.RectOptKey], rect)
        
        rect = CGRect(x: 5, y: 6, width: 7, height: 8)
        defaults[.RectOptKey] = rect
        XCTAssertEqual(defaults[.RectOptKey], rect)
    }
    
    func testContainment() {
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertTrue(defaults.contains(.StringKey))
    }
    
    func testRemoving() {
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertNil(defaults[.StringOptKey])
        
        defaults[.StringOptKey] = "foo"
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        
        XCTAssert(defaults.contains(.StringOptKey))
        XCTAssertNotNil(defaults[.StringOptKey])
        
        defaults.remove(.StringOptKey)
        
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertNil(defaults[.StringOptKey])
    }
    
    func testRemovingAll() {
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertNil(defaults[.StringOptKey])
        
        defaults[.StringOptKey] = "foo"
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        
        XCTAssert(defaults.contains(.StringOptKey))
        XCTAssertNotNil(defaults[.StringOptKey])
        
        defaults.removeAll()
        
        XCTAssertFalse(defaults.contains(.StringOptKey))
        XCTAssertNil(defaults[.StringOptKey])
    }
    
    // MARK: -
    
    func testRegistration() {
        let rect = CGRect(x: 1, y: 2, width: 3, height: 4)
        
        XCTAssertEqual(defaults[.IntKey], 0)
        XCTAssertNil(defaults[.StringOptKey])
        XCTAssertNil(defaults[.ColorOptKey])
        XCTAssertNil(defaults[.RectOptKey])
        
        let dict: [UserDefaults.DefaultKeys : Any] = [
            .IntKey: 42,
            .StringOptKey: "foo",
            .ColorOptKey: Color.red,
            .RectOptKey: rect,
        ]
        defaults.register(defaults: dict)
        
        XCTAssertEqual(defaults[.IntKey], 42)
        XCTAssertEqual(defaults[.StringOptKey], "foo")
        XCTAssertEqual(defaults[.ColorOptKey], .red)
        XCTAssertEqual(defaults[.RectOptKey], rect)
        
        defaults.unregisterAll()
    }
    
    func testObserving() {
        let ex = expectation(description: "observing get called")
        #if !os(macOS)
            // FIXME: KVO get called twice on iOS/tvOS. Why?
            ex.expectedFulfillmentCount = 2
        #endif
        defaults[.IntKey] = 233
        let token = defaults.observe(.IntKey, options: [.old, .new]) { (defaults, change) in
            #if os(macOS)
            XCTAssertEqual(change.oldValue, 233)
            XCTAssertEqual(change.newValue, 234)
            #endif
            ex.fulfill()
        }
        defaults[.IntKey] = 234
        token.invalidate()
        defaults[.IntKey] = 123
        waitForExpectations(timeout: 0)
    }
    
    func testObservingWithArchiving() {
        let ex = expectation(description: "observing get called")
        #if !os(macOS)
            ex.expectedFulfillmentCount = 2
        #endif
        defaults[.ColorOptKey] = .red
        let token = defaults.observe(.ColorOptKey, options: [.old, .new]) { (defaults, change) in
            #if os(macOS)
            XCTAssertEqual(change.oldValue, .red)
            XCTAssertEqual(change.newValue, .green)
            #endif
            ex.fulfill()
        }
        defaults[.ColorOptKey] = .green
        token.invalidate()
        defaults[.ColorOptKey] = .blue
        waitForExpectations(timeout: 0)
    }
    
    func testObservingWithCoding() {
        let ex = expectation(description: "observing get called")
        #if !os(macOS)
            ex.expectedFulfillmentCount = 2
        #endif
        let rect1 = CGRect(x: 1, y: 2, width: 3, height: 4)
        let rect2 = CGRect(x: 5, y: 6, width: 7, height: 8)
        defaults[.RectOptKey] = rect1
        let token = defaults.observe(.RectOptKey, options: [.old, .new]) { (defaults, change) in
            #if os(macOS)
            XCTAssertEqual(change.oldValue, rect1)
            XCTAssertEqual(change.newValue, rect2)
            #endif
            ex.fulfill()
        }
        defaults[.RectOptKey] = rect2
        token.invalidate()
        defaults[.RectOptKey] = rect1
        waitForExpectations(timeout: 0)
    }
    
    func testObservingMultipleKeys() {
        let ex = expectation(description: "observing get called")
        #if os(macOS)
            ex.expectedFulfillmentCount = 2
        #else
            // FIXME: KVO get called twice on iOS/tvOS. Why?
            ex.expectedFulfillmentCount = 4
        #endif
        let token = defaults.observe([.IntKey, .StringKey], options: [.old, .new]) {
            ex.fulfill()
        }
        defaults[.IntKey] = 42
        defaults[.StringKey] = "foo"
        token.invalidate()
        defaults[.IntKey] = 123
        waitForExpectations(timeout: 0)
    }
    
}
