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
        XCTAssertNil(obj[.ValueTypeKey])
        
        obj[.ValueTypeKey] = 10
        XCTAssertEqual(obj[.ValueTypeKey], 10)
        
        obj[.ValueTypeKey] = 20
        XCTAssertEqual(obj[.ValueTypeKey], 20)
    }
    
    func testReferenceType() {
        let obj = NSObject()
        XCTAssertNil(obj[.ReferenceTypeKey])
        
        var date = NSDate()
        obj[.ReferenceTypeKey] = date
        XCTAssertEqual(obj[.ReferenceTypeKey], date)
        
        date = NSDate()
        obj[.ReferenceTypeKey] = date
        XCTAssertEqual(obj[.ReferenceTypeKey], date)
    }
    
    func testRemoving() {
        let obj = NSObject()
        XCTAssertNil(obj[.ValueTypeKey])
        
        obj[.ValueTypeKey] = 233
        XCTAssertEqual(obj[.ValueTypeKey], 233)
        
        obj.removeAssociateValue(for: .ValueTypeKey)
        XCTAssertNil(obj[.ValueTypeKey])
    }
    
    func testRemovingAll() {
        let obj = NSObject()
        XCTAssertNil(obj[.ValueTypeKey])
        XCTAssertNil(obj[.ReferenceTypeKey])
        
        
        let date = NSDate()
        obj[.ReferenceTypeKey] = date
        XCTAssertEqual(obj[.ReferenceTypeKey], date)

        obj[.ValueTypeKey] = 233
        XCTAssertEqual(obj[.ValueTypeKey], 233)
        
        obj.removeAssociateValues()
        XCTAssertNil(obj[.ValueTypeKey])
        XCTAssertNil(obj[.ReferenceTypeKey])
    }
    
    func testDynamicKey() {
        let key: NSObject.AssociateKey<Int> = "ValueTypeKey"
        let obj = NSObject()
        XCTAssertNil(obj[.ValueTypeKey])
        XCTAssertNil(obj[key])
        
        obj[.ValueTypeKey] = 10
        XCTAssertEqual(obj[key], 10)
        
        obj[key] = 20
        XCTAssertEqual(obj[.ValueTypeKey], 20)
    }
    
}
