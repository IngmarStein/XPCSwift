//
//  XPCObject.swift
//  XPCSwift
//
//  Created by Ingmar Stein on 21.07.14.
//
//

import XPC

public enum XPCObject {
	case XPCBool(xpc_object_t)
	case XPCInt64(xpc_object_t)
	case XPCUInt64(xpc_object_t)
	case XPCString(xpc_object_t)
	case XPCDouble(xpc_object_t)
	case XPCData(xpc_object_t)
	case XPCArray(xpc_object_t)
	case XPCDictionary(xpc_object_t)
	case Unknown(xpc_object_t)

	public init(_ object : xpc_object_t) {
		let type = xpc_get_type(object)
		switch type {
		case xpc_type_bool:
			self = .XPCBool(object)
		case xpc_type_int64:
			self = .XPCInt64(object)
		case xpc_type_uint64:
			self = .XPCUInt64(object)
		case xpc_type_string:
			self = .XPCString(object)
		case xpc_type_double:
			self = .XPCDouble(object)
		case xpc_type_data:
			self = .XPCData(object)
		case xpc_type_array:
			self = .XPCArray(object)
		case xpc_type_dictionary:
			self = .XPCDictionary(object)
		default:
			self = .Unknown(object)
		}
	}

	public init(_ value : Bool) {
		self = .XPCBool(xpc_bool_create(value))
	}
	
	public init(_ value : Int64) {
		self = .XPCInt64(xpc_int64_create(value))
	}
	
	public init(_ value : UInt64) {
		self = .XPCUInt64(xpc_uint64_create(value))
	}
	
	public init(_ value : String) {
		self = .XPCString(value.withCString { xpc_string_create($0) })
	}
	
	public init(_ value : Double) {
		self = .XPCDouble(xpc_double_create(value))
	}
	
	public init(_ value : NSData) {
		self = .XPCData(xpc_data_create(value.bytes, value.length))
	}

	public init(_ array: [XPCObject]) {
		let xpc_array = xpc_array_create(nil, 0)
		for value in array {
			xpc_array_append_value(xpc_array, value.object)
		}
		self = .XPCArray(xpc_array)
	}

	public init(_ dictionary: [String:XPCObject]) {
		let xpc_dictionary = xpc_dictionary_create(nil, nil, 0)
		for (key, value) in dictionary {
			key.withCString { xpc_dictionary_set_value(xpc_dictionary, $0, value.object) }
		}
		self = .XPCDictionary(xpc_dictionary)
	}

	public var object : xpc_object_t {
	switch self {
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
	case .XPCArray(let value):
		return value
	case .XPCDictionary(let value):
		return value
	case .Unknown(let value):
		return value
	}
	}
}

// MARK: - Printing

 extension XPCObject : Printable, DebugPrintable {
	public var description : String {
		switch self {
		case XPCBool(let value):
			return xpc_bool_get_value(value).description
		case XPCInt64(let value):
			return xpc_int64_get_value(value).description
		case XPCUInt64(let value):
			return xpc_uint64_get_value(value).description
		case XPCString(let value):
			return String.fromCString(xpc_string_get_string_ptr(value)) ?? "<ill-formed UTF-8 code unit sequence>"
		case XPCDouble(let value):
			return xpc_double_get_value(value).description
		case XPCData(let value):
			return value.description
		case XPCArray(let value):
			return value.description
		case XPCDictionary(let value):
			return value.description
		case Unknown(let value):
			return value.description
		}
	}

	public var debugDescription : String {
		return description
	}
}

// MARK: - Literals

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
	public init(arrayLiteral elements: XPCObject...) {
		self.init(elements)
	}
}

extension XPCObject : DictionaryLiteralConvertible {
	public init(dictionaryLiteral elements: (String, XPCObject)...) {
		var dict = [String:XPCObject]()
		for (k, v) in elements {
			dict[k] = v
		}
		
		self.init(dict)
	}
}

// MARK: - Accessors

public extension XPCObject {
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
			case XPCArray(let value):
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
