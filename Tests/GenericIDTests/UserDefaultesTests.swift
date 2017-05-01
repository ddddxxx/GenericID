//
//  UserDefaultesTests.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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
        defaults.removeAll()
    }
    
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
    
    func testArchiving() {
        XCTAssertNil(defaults.unarchive(.ColorKey))
        
        var color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        defaults.archive(color, for: .ColorKey)
        XCTAssertEqual(defaults.unarchive(.ColorKey), color)
        
        color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        defaults.archive(color, for: .ColorKey)
        XCTAssertEqual(defaults.unarchive(.ColorKey), color)
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
    
    func testKVO() {
        var exec = false
        defaults[.IntKey] = 233
        let token = defaults.addObserver(key: .IntKey) { change in
            XCTAssertEqual(change.oldValue, 233)
            XCTAssertEqual(change.newValue, 234)
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
        let token = defaults.addObserver(key: .ColorKey) { change in
            XCTAssertEqual(change.oldValue, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            XCTAssertEqual(change.newValue, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
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
    static let ColorKey: Key<Color> = "ColorKey"
    static let AnyKey: Key<Any?> = "AnyKey"
}
