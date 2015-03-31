//
//  XPCSwiftTests.swift
//  XPCSwiftTests
//
//  Created by Ingmar Stein on 30.03.15.
//  Copyright (c) 2015 Ingmar Stein. All rights reserved.
//

import Cocoa
import XCTest
import XPCSwift

class XPCSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

	// MARK: - Roundtrips
    
	func testBool() {
		XCTAssert(XPCObject(true).bool! == true, "true")
		XCTAssert(XPCObject(false).bool! == false, "true")
	}

	func testInt64() {
		XCTAssert(XPCObject(Int64.max).int64! == Int64.max, "Int64.max")
		XCTAssert(XPCObject(Int64.allZeros).int64! == Int64.allZeros, "0")
		XCTAssert(XPCObject(Int64.min).int64! == Int64.min, "Int64.min")
	}

	func testUInt64() {
		XCTAssert(XPCObject(UInt64.max).uint64! == UInt64.max, "UInt64.max")
		XCTAssert(XPCObject(UInt64.allZeros).uint64! == UInt64.allZeros, "0")
		XCTAssert(XPCObject(UInt64.min).uint64! == UInt64.min, "UInt64.min")
	}

	func testDouble() {
		XCTAssert(XPCObject(DBL_MAX).double! == DBL_MAX, "DBL_MAX")
		XCTAssert(XPCObject(DBL_MIN).double! == DBL_MIN, "DBL_MIN")
	}

	func testDate() {
		let date = NSDate()
		XCTAssertEqualWithAccuracy(XPCObject(date).date!.timeIntervalSince1970, date.timeIntervalSince1970, DBL_EPSILON, "date")
	}

	func testFileHandle() {
		let fileHandle = NSFileHandle(fileDescriptor: 0)
		XCTAssert(XPCObject(fileHandle).fileHandle != nil, "file descriptor should not be nil")
	}
	
	func testUUID() {
		let uuid = NSUUID()
		XCTAssertEqual(XPCObject(uuid).uuid!, uuid, "uuid")
	}

	// MARK: - To XPC

	func testEmptyToXPC() {
		let xpcArray = XPCObject([])

		XCTAssert(xpc_array_get_count(xpcArray.object) == 0, "array should be empty")
	}

	func testPopulatedArrayToXPC() {
		let xpcArray = XPCObject([ Int64(1234), "test" ])

		XCTAssert(xpc_array_get_count(xpcArray.object) == 2, "array should have two elements")
		XCTAssert(xpc_array_get_int64(xpcArray.object, 0) == 1234, "array should contain integer")
		XCTAssert(String.fromCString(xpc_array_get_string(xpcArray.object, 1))! == "test", "array should contain string")
	}

	func testComplexArrayToXPC() {
		let nestedArray : [XPCRepresentable] = [ Int64(1234), true ]
		let nestedDict : [String:XPCRepresentable] = [ "key1" : "val1", "key2" : Int64(-2727) ]

		let xpcArray = XPCObject( [nestedArray, "more", nestedDict] )

		XCTAssert(xpc_array_get_count(xpcArray.object) == 3, "array should have three elements")

		let nestedXPCArray = xpc_array_get_value(xpcArray.object, 0)
		XCTAssert(xpc_array_get_count(nestedXPCArray) == 2, "nested array should have two elements")
		XCTAssert(xpc_array_get_int64(nestedXPCArray, 0) == 1234, "nested array should contain integer")
		XCTAssert(xpc_array_get_bool(nestedXPCArray, 1) == true, "nested array should contain boolean")

		XCTAssert(String.fromCString(xpc_array_get_string(xpcArray.object, 1))! == "more", "array should contain string")

		let nestedXPCDict = xpc_array_get_value(xpcArray.object, 2)
		XCTAssert(xpc_dictionary_get_count(nestedXPCDict) == 2, "nested dictionary should have two elements")
		XCTAssert(String.fromCString(xpc_dictionary_get_string(nestedXPCDict, "key1"))! == "val1", "nested dictionary should contain string")
		XCTAssert(xpc_dictionary_get_int64(nestedXPCDict, "key2") == -2727, "nested dictionary should contain integer")
	}

	// MARK: - From XPC

	func testEmptyToSwift() {
		let xpcArray = xpc_array_create(nil, 0)
		let array = XPCObject(xpcArray).array!

		XCTAssert(array.isEmpty, "Bad array count")
	}

	func testPopulatedToSwift() {
		let xpcArray = xpc_array_create(nil, 0)
		xpc_array_append_value(xpcArray, xpc_bool_create(true))
		"안녕".withCString { xpc_array_append_value(xpcArray, xpc_string_create($0)) }

		let array = XPCObject(xpcArray).array!

		XCTAssertEqual(array.count, 2, "Bad array count")
		XCTAssertEqual(array[0].bool!, true, "basic boolean")
		XCTAssertEqual(array[1].string!, "안녕", "basic string")
	}

	func testComplexToSwift() {
		let nestedXPCArray = xpc_array_create(nil, 0)
		xpc_array_append_value(nestedXPCArray, xpc_double_create(27.38237))

		let nestedXPCDict = xpc_dictionary_create(nil, nil, 0)
		xpc_dictionary_set_string(nestedXPCDict, "someKey", "foo bar")
		xpc_dictionary_set_int64(nestedXPCDict, "otherKey", 12345)

		let xpcArray = xpc_array_create(nil, 0)
		xpc_array_append_value(xpcArray, nestedXPCDict)
		xpc_array_append_value(xpcArray, nestedXPCArray)

		let array = XPCObject(xpcArray).array!

		XCTAssertEqual(array.count, 2, "Bad array count")

		let nestedDict = array[0].dictionary!
		XCTAssertEqual(nestedDict.count, 2, "Bad nested dictionary count")
		XCTAssertEqual(nestedDict["someKey"]!.string!, "foo bar", "basic string")
		XCTAssertEqual(nestedDict["otherKey"]!.int64!, 12345, "basic number")

		let nestedArray = array[1].array!
		XCTAssertEqual(nestedArray.count, 1, "Bad nested array count")
		XCTAssertEqualWithAccuracy(nestedArray[0].double!, 27.38237, DBL_EPSILON, "basic double")
	}

}
