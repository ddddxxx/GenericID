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
    
    func testArray() {
        XCTAssertNil(defaults[.ArrayKey])
        
        defaults[.ArrayKey] = [true, 233, 3.14]
        XCTAssertEqual(defaults[.ArrayKey]?[0] as? Bool,   true)
        XCTAssertEqual(defaults[.ArrayKey]?[1] as? Int,    233)
        XCTAssertEqual(defaults[.ArrayKey]?[2] as? Double, 3.14)
        
        defaults[.ArrayKey]?.append("foo")
        XCTAssertEqual(defaults[.ArrayKey]?[3] as? String, "foo")
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
    
}

extension UserDefaults.DefaultKeys {
    static let BoolKey: Key<Bool> = "BoolKey"
    static let IntKey: Key<Int> = "IntKey"
    static let FloatKey: Key<Float> = "FloatKey"
    static let DoubleKey: Key<Double> = "DoubleKey"
    static let StringKey: Key<String> = "StringKey"
    static let URLKey: Key<URL> = "URLKey"
    static let ArrayKey: Key<[Any]> = "ArrayKey"
    static let DictionaryKey: Key<[String: Any]> = "DictionaryKey"
    static let ColorKey: Key<Color> = "ColorKey"
}
