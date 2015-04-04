//
//  XPCObject.swift
//  XPCSwift
//
//  Created by Ingmar Stein on 21.07.14.
//
//

import Foundation
import XPC

private let xpcDateInterval : NSTimeInterval = 1000000000.0

// XPC_TYPE_* constants are not visible in Swift (as of Xcode 6.3b4)
// remove the following as soon as this is fixed
private let xpc_type_null = xpc_get_type(xpc_null_create())
private let xpc_type_bool = xpc_get_type(xpc_bool_create(false))
private let xpc_type_int64 = xpc_get_type(xpc_int64_create(0))
private let xpc_type_uint64 = xpc_get_type(xpc_uint64_create(0))
private let xpc_type_string = xpc_get_type(xpc_string_create(""))
private let xpc_type_double = xpc_get_type(xpc_double_create(0.0))
private let xpc_type_data = xpc_get_type(xpc_data_create(nil, 0))
private let xpc_type_array = xpc_get_type(xpc_array_create(nil, 0))
private let xpc_type_dictionary = xpc_get_type(xpc_dictionary_create(nil, nil, 0))
private let xpc_type_date = xpc_get_type(xpc_date_create_from_current())
private let xpc_type_fd = xpc_get_type(xpc_fd_create(0))
private let xpc_type_uuid = xpc_get_type(xpc_uuid_create([UInt8](count: 16, repeatedValue: 0)))

// Marker protocol for types which can be represented as XPC types
public protocol XPCRepresentable {}
extension Bool: XPCRepresentable {}
extension Int64: XPCRepresentable {}
extension UInt64: XPCRepresentable {}
extension String: XPCRepresentable {}
extension Double: XPCRepresentable {}
extension NSData: XPCRepresentable {}
extension Array: XPCRepresentable {}
extension Dictionary: XPCRepresentable {}
extension NSDate: XPCRepresentable {}
extension NSFileHandle: XPCRepresentable {}
extension NSUUID: XPCRepresentable {}
extension NSNull: XPCRepresentable {}

public enum XPCObject : XPCRepresentable {
	case XPCNull(xpc_object_t)
	case XPCBool(xpc_object_t)
	case XPCInt64(xpc_object_t)
	case XPCUInt64(xpc_object_t)
	case XPCString(xpc_object_t)
	case XPCDouble(xpc_object_t)
	case XPCData(xpc_object_t)
	case XPCArray(xpc_object_t)
	case XPCDictionary(xpc_object_t)
	case XPCDate(xpc_object_t)
	case XPCFileHandle(xpc_object_t)
	case XPCUUID(xpc_object_t)
	case Unknown(xpc_object_t)

	public init(_ object : xpc_object_t) {
		let type = xpc_get_type(object)
		switch type {
		case xpc_type_null:
			self = XPCNull(object)
		case xpc_type_bool:
			self = XPCBool(object)
		case xpc_type_int64:
			self = XPCInt64(object)
		case xpc_type_uint64:
			self = XPCUInt64(object)
		case xpc_type_string:
			self = XPCString(object)
		case xpc_type_double:
			self = XPCDouble(object)
		case xpc_type_data:
			self = XPCData(object)
		case xpc_type_array:
			self = XPCArray(object)
		case xpc_type_dictionary:
			self = XPCDictionary(object)
		case xpc_type_dictionary:
			self = XPCDictionary(object)
		case xpc_type_date:
			self = XPCDate(object)
		case xpc_type_fd:
			self = XPCFileHandle(object)
		case xpc_type_uuid:
			self = XPCUUID(object)
		default:
			self = Unknown(object)
		}
	}

	public init(_ value : XPCRepresentable) {
		switch value {
		case let value as NSNull:
			self.init(value)
		case let value as Bool:
			self.init(value)
		case let value as Int64:
			self.init(value)
		case let value as UInt64:
			self.init(value)
		case let value as String:
			self.init(value)
		case let value as Double:
			self.init(value)
		case let value as NSData:
			self.init(value)
		case let value as [XPCRepresentable]:
			self.init(value)
		case let value as [String:XPCRepresentable]:
			self.init(value)
		case let value as NSDate:
			self.init(value)
		case let value as NSFileHandle:
			self.init(value)
		case let value as NSUUID:
			self.init(value)
		case let value as XPCObject:
			self.init(value.object)
		default:
			// Should never happen because we've checked all XPCRepresentable types
			// Swift 1.2: arrays of types conforming to XPCRepresentable (e.g. [String]) cannot be cast to [XPCRepresentable]
			// Make sure to use the protocol type when declaring the array (c.f. testArrayCast)
			fatalError("Unhandled type in XPCObject.init(XPCRepresentable): \(value)")
		}
	}

	public init(_ : NSNull) {
		self = XPCNull(xpc_null_create())
	}

	public init(_ value : Bool) {
		self = XPCBool(xpc_bool_create(value))
	}

	public init(_ value : Int64) {
		self = XPCInt64(xpc_int64_create(value))
	}
	
	public init(_ value : UInt64) {
		self = XPCUInt64(xpc_uint64_create(value))
	}
	
	public init(_ value : String) {
		self = XPCString(value.withCString { xpc_string_create($0) })
	}
	
	public init(_ value : Double) {
		self = XPCDouble(xpc_double_create(value))
	}
	
	public init(_ value : NSData) {
		self = XPCData(xpc_data_create(value.bytes, value.length))
	}

	public init(_ value : NSDate) {
		self = XPCDate(xpc_date_create(Int64(value.timeIntervalSince1970 * xpcDateInterval)))
	}

	public init(_ value : NSFileHandle) {
		self = XPCFileHandle(xpc_fd_create(value.fileDescriptor))
	}

	public init(_ value : NSUUID) {
		var bytes = [UInt8](count: 16, repeatedValue: 0)
		value.getUUIDBytes(&bytes)
		self = XPCUUID(xpc_uuid_create(bytes))
	}

	public init(_ array: [XPCRepresentable]) {
		let xpc_array = xpc_array_create(nil, 0)
		for value in array {
			xpc_array_append_value(xpc_array, XPCObject(value).object)
		}
		self = XPCArray(xpc_array)
	}

	public init(_ dictionary: [String:XPCRepresentable]) {
		let xpc_dictionary = xpc_dictionary_create(nil, nil, 0)
		for (key, value) in dictionary {
			key.withCString { xpc_dictionary_set_value(xpc_dictionary, $0, XPCObject(value).object) }
		}
		self = XPCDictionary(xpc_dictionary)
	}

	public var object : xpc_object_t {
	switch self {
	case XPCNull(let value):
		return value
	case XPCBool(let value):
		return value
	case XPCInt64(let value):
		return value
	case XPCUInt64(let value):
		return value
	case XPCString(let value):
		return value
	case XPCDouble(let value):
		return value
	case XPCData(let value):
		return value
	case XPCArray(let value):
		return value
	case XPCDictionary(let value):
		return value
	case XPCDate(let value):
		return value
	case XPCFileHandle(let value):
		return value
	case XPCUUID(let value):
		return value
	case Unknown(let value):
		return value
	}
	}
}

// MARK: - Printing

extension XPCObject : Printable, DebugPrintable {
	public var description : String {
		return object.description
	}

	public var debugDescription : String {
		return description
	}
}

// MARK: - Equatable

public func ==(lhs: XPCObject, rhs: XPCObject) -> Bool {
	return xpc_equal(lhs.object, rhs.object)
}

// MARK: - Hashable

extension XPCObject : Hashable {
	public var hashValue: Int {
		return xpc_hash(object)
	}
}

// MARK: - Literals

extension XPCObject : NilLiteralConvertible {
	public init(nilLiteral: ()) {
		self.init(NSNull())
	}
}

extension XPCObject : BooleanLiteralConvertible {
	public init(booleanLiteral value: BooleanLiteralType) {
		self.init(value)
	}
}

extension XPCObject : IntegerLiteralConvertible {
	public init(integerLiteral value: IntegerLiteralType) {
		self.init(value)
	}
}

extension XPCObject : FloatLiteralConvertible {
	public init(floatLiteral value: FloatLiteralType) {
		self.init(value)
	}
}

extension XPCObject : StringLiteralConvertible {
	public init(stringLiteral value: StringLiteralType) {
		self.init(value)
	}
	public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
		self.init(value)
	}
	public init(unicodeScalarLiteral value: StringLiteralType) {
		self.init(value)
	}
}

extension XPCObject : ArrayLiteralConvertible {
	public init(arrayLiteral elements: XPCRepresentable...) {
		self.init(elements)
	}
}

extension XPCObject : DictionaryLiteralConvertible {
	public init(dictionaryLiteral elements: (String, XPCRepresentable)...) {
		var dict = [String:XPCRepresentable]()
		for (k, v) in elements {
			dict[k] = v
		}
		
		self.init(dict)
	}
}

// MARK: - Accessors

public extension XPCObject {
	public var null: NSNull? {
		get {
			switch self {
			case XPCNull:
				return NSNull()
			default:
				return nil
			}
		}
	}

	public var bool: Bool? {
		get {
			switch self {
			case XPCBool(let value):
				return xpc_bool_get_value(value)
			default:
				return nil
			}
		}
	}

	public var int64: Int64? {
		get {
			switch self {
			case XPCInt64(let value):
				return xpc_int64_get_value(value)
			default:
				return nil
			}
		}
	}

	public var uint64: UInt64? {
		get {
			switch self {
			case XPCUInt64(let value):
				return xpc_uint64_get_value(value)
			default:
				return nil
			}
		}
	}

	public var string: String? {
		get {
			switch self {
			case XPCString(let value):
				return String.fromCString(xpc_string_get_string_ptr(value))
			default:
				return nil
			}
		}
	}

	public var double: Double? {
		get {
			switch self {
			case XPCDouble(let value):
				return xpc_double_get_value(value)
			default:
				return nil
			}
		}
	}

	public var data: NSData? {
		get {
			switch self {
			case XPCData(let value):
				return NSData(bytes: xpc_data_get_bytes_ptr(value), length: xpc_data_get_length(value))
			default:
				return nil
			}
		}
	}

	public var array: [XPCObject]? {
		get {
			switch self {
			case XPCArray(let value):
				var result = [XPCObject]()
				xpc_array_apply(value) { (_, element) -> Bool in
					result.append(XPCObject(element))
					return true
				}
				return result
			default:
				return nil
			}
		}
	}

	public var dictionary: [String:XPCObject]? {
		get {
			switch self {
			case XPCDictionary(let value):
				var result = [String:XPCObject]()
				xpc_dictionary_apply(value) { (key, value) -> Bool in
					if let key = String.fromCString(key) {
						result[key] = XPCObject(value)
					}
					return true
				}
				return result
			default:
				return nil
			}
		}
	}

	public var date: NSDate? {
		get {
			switch self {
			case XPCDate(let value):
				return NSDate(timeIntervalSince1970: NSTimeInterval(xpc_date_get_value(value)) / xpcDateInterval)
			default:
				return nil
			}
		}
	}

	public var fileHandle: NSFileHandle? {
		get {
			switch self {
			case XPCFileHandle(let value):
				return NSFileHandle(fileDescriptor: xpc_fd_dup(value), closeOnDealloc: true)
			default:
				return nil
			}
		}
	}

	public var uuid: NSUUID? {
		get {
			switch self {
			case XPCUUID(let value):
				return NSUUID(UUIDBytes: xpc_uuid_get_bytes(value))
			default:
				return nil
			}
		}
	}
}

/*
// MARK: - Conversion

extension Bool {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension Int64 {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension UInt64 {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension String {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension Double {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension NSData {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension Array {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}

extension Dictionary {
	func __conversion() -> XPCObject {
		return XPCObject(self)
	}
}
*/
