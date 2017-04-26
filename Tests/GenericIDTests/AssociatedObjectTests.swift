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
        XCTAssertEqual(obj.associatedValue(for: .ValueTypeKey), 10)
        
        obj.set(20, for: .ValueTypeKey)
        XCTAssertEqual(obj.associatedValue(for: .ValueTypeKey), 20)
    }
    
    func testReferenceType() {
        let obj = NSObject()
        XCTAssertNil(obj.associatedValue(for: .ReferenceTypeKey))
        
        var date = NSDate()
        obj.set(date, for: .ReferenceTypeKey)
        XCTAssertEqual(obj.associatedValue(for: .ReferenceTypeKey), date)
        
        date = NSDate()
        obj.set(date, for: .ReferenceTypeKey)
        XCTAssertEqual(obj.associatedValue(for: .ReferenceTypeKey), date)
    }
    
    func testRemoving() {
        let obj = NSObject()
        XCTAssertNil(obj.associatedValue(for: .ValueTypeKey))
        
        obj.set(233, for: .ValueTypeKey)
        XCTAssertEqual(obj.associatedValue(for: .ValueTypeKey), 233)
        
        obj.removeAssociateValue(for: .ValueTypeKey)
        XCTAssertNil(obj.associatedValue(for: .ValueTypeKey))
    }
    
}

extension NSObject.AssociateKeys {
    static let ValueTypeKey: Key<Int>           = "ValueTypeKey"
    static let ReferenceTypeKey: Key<NSDate>    = "ReferenceTypeKey"
}
