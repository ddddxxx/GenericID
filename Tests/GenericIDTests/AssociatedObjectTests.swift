//
//  AssociatedObjectTests.swift
//  GenericIDTests
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import XCTest
@testable import GenericID

class AssociatedObjectTests: XCTestCase {
    
    func testValueType() {
        let obj = NSObject()
        XCTAssertNil(obj.associatedValue(for: .ValueTypeKey))
        obj.set(10, for: .ValueTypeKey)
        XCTAssert(obj.associatedValue(for: .ValueTypeKey) == 10)
        obj.set(20, for: .ValueTypeKey)
        XCTAssert(obj.associatedValue(for: .ValueTypeKey) == 20)
    }
    
    func testReferenceType() {
        let obj = NSObject()
        var date = NSDate()
        XCTAssertNil(obj.associatedValue(for: .ReferenceTypeKey))
        obj.set(date, for: .ReferenceTypeKey)
        XCTAssert(obj.associatedValue(for: .ReferenceTypeKey) == date)
        date = NSDate()
        obj.set(date, for: .ReferenceTypeKey)
        XCTAssert(obj.associatedValue(for: .ReferenceTypeKey) == date)
    }
    
}

extension NSObject.AssociateKeys {
    static let ValueTypeKey: Key<Int>           = "ValueTypeKey"
    static let ReferenceTypeKey: Key<NSDate>    = "ReferenceTypeKey"
}
