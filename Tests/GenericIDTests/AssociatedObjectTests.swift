//
//  AssociatedObjectTests.swift
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
    
    func testRemovingAll() {
        let obj = NSObject()
        XCTAssertNil(obj.associatedValue(for: .ValueTypeKey))
        XCTAssertNil(obj.associatedValue(for: .ReferenceTypeKey))
        
        
        let date = NSDate()
        obj.set(date, for: .ReferenceTypeKey)
        XCTAssertEqual(obj.associatedValue(for: .ReferenceTypeKey), date)

        obj.set(233, for: .ValueTypeKey)
        XCTAssertEqual(obj.associatedValue(for: .ValueTypeKey), 233)
        
        obj.removeAssociateValues()
        XCTAssertNil(obj.associatedValue(for: .ValueTypeKey))
        XCTAssertNil(obj.associatedValue(for: .ReferenceTypeKey))
    }
    
    func testDynamicKey() {
        let key: NSObject.AssociateKey<Int> = "ValueTypeKey"
        let obj = NSObject()
        XCTAssertNil(obj.associatedValue(for: .ValueTypeKey))
        XCTAssertNil(obj.associatedValue(for: key))
        
        obj.set(10, for: .ValueTypeKey)
        XCTAssertEqual(obj.associatedValue(for: key), 10)
        
        obj.set(20, for: key)
        XCTAssertEqual(obj.associatedValue(for: .ValueTypeKey), 20)
    }
    
}
