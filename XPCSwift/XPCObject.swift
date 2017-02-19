//
//  XPCObject.swift
//  XPCSwift
//
//  Created by Ingmar Stein on 21.07.14.
//
//

import Foundation
import XPC

private let xpcDateInterval: TimeInterval = 1000000000.0

// XPC_TYPE_* constants are not visible in Swift (as of Xcode 8.2)
// remove the following as soon as this is fixed
private let xpc_type_null = xpc_get_type(xpc_null_create())
private let xpc_type_bool = xpc_get_type(xpc_bool_create(false))
private let xpc_type_int64 = xpc_get_type(xpc_int64_create(0))
private let xpc_type_uint64 = xpc_get_type(xpc_uint64_create(0))
private let xpc_type_string = xpc_get_type(xpc_string_create(""))
private let xpc_type_double = xpc_get_type(xpc_double_create(0.0))
private let xpc_type_data = xpc_get_type(xpc_data_create(UnsafeMutableRawPointer.allocate(bytes: 0, alignedTo: 0), 0))
private let xpc_type_array = xpc_get_type(xpc_array_create(nil, 0))
private let xpc_type_dictionary = xpc_get_type(xpc_dictionary_create(nil, nil, 0))
private let xpc_type_date = xpc_get_type(xpc_date_create_from_current())
private let xpc_type_fd = xpc_get_type(xpc_fd_create(0)!)
private let xpc_type_uuid = xpc_get_type(xpc_uuid_create([UInt8](repeating: 0, count: 16)))

// Marker protocol for types which can be represented as XPC types
public protocol XPCRepresentable {}
extension Bool: XPCRepresentable {}
extension Int64: XPCRepresentable {}
extension UInt64: XPCRepresentable {}
extension String: XPCRepresentable {}
extension Double: XPCRepresentable {}
extension Data: XPCRepresentable {}
extension Array: XPCRepresentable {}
extension Dictionary: XPCRepresentable {}
extension Date: XPCRepresentable {}
extension FileHandle: XPCRepresentable {}
extension UUID: XPCRepresentable {}
extension NSNull: XPCRepresentable {}

public enum XPCObject: XPCRepresentable {
	case xpcNull(xpc_object_t)
	case xpcBool(xpc_object_t)
	case xpcInt64(xpc_object_t)
	case xpcuInt64(xpc_object_t)
	case xpcString(xpc_object_t)
	case xpcDouble(xpc_object_t)
	case xpcData(xpc_object_t)
	case xpcArray(xpc_object_t)
	case xpcDictionary(xpc_object_t)
	case xpcDate(xpc_object_t)
	case xpcFileHandle(xpc_object_t)
	case xpcuuid(xpc_object_t)
	case unknown(xpc_object_t)

	public init(_ object: xpc_object_t) {
		let type = xpc_get_type(object)
		switch type {
		case xpc_type_null:
			self = .xpcNull(object)
		case xpc_type_bool:
			self = .xpcBool(object)
		case xpc_type_int64:
			self = .xpcInt64(object)
		case xpc_type_uint64:
			self = .xpcuInt64(object)
		case xpc_type_string:
			self = .xpcString(object)
		case xpc_type_double:
			self = .xpcDouble(object)
		case xpc_type_data:
			self = .xpcData(object)
		case xpc_type_array:
			self = .xpcArray(object)
		case xpc_type_dictionary:
			self = .xpcDictionary(object)
		case xpc_type_dictionary:
			self = .xpcDictionary(object)
		case xpc_type_date:
			self = .xpcDate(object)
		case xpc_type_fd:
			self = .xpcFileHandle(object)
		case xpc_type_uuid:
			self = .xpcuuid(object)
		default:
			self = .unknown(object)
		}
	}

	public init(_ value: XPCRepresentable) {
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
		case let value as Data:
			self.init(value)
		case let value as [XPCRepresentable]:
			self.init(value)
		case let value as [String:XPCRepresentable]:
			self.init(value)
		case let value as Date:
			self.init(value)
		case let value as FileHandle:
			self.init(value)!
		case let value as UUID:
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

	public init(_: NSNull) {
		self = .xpcNull(xpc_null_create())
	}

	public init(_ value: Bool) {
		self = .xpcBool(xpc_bool_create(value))
	}

	public init(_ value: Int64) {
		self = .xpcInt64(xpc_int64_create(value))
	}
	
	public init(_ value: UInt64) {
		self = .xpcuInt64(xpc_uint64_create(value))
	}
	
	public init(_ value: String) {
		self = .xpcString(value.withCString { xpc_string_create($0) })
	}
	
	public init(_ value: Double) {
		self = .xpcDouble(xpc_double_create(value))
	}
	
	public init(_ value: Data) {
		self = .xpcData(xpc_data_create((value as NSData).bytes, value.count))
	}

	public init(_ value: Date) {
		self = .xpcDate(xpc_date_create(Int64(value.timeIntervalSince1970 * xpcDateInterval)))
	}

	public init?(_ value: FileHandle) {
		if let xpcFd = xpc_fd_create(value.fileDescriptor) {
			self = .xpcFileHandle(xpcFd)
		} else {
			return nil
		}
	}

	public init(_ value: UUID) {
		var bytes = [UInt8](repeating: 0, count: 16)
		(value as NSUUID).getBytes(&bytes)
		self = .xpcuuid(xpc_uuid_create(bytes))
	}

	public init(_ array: [XPCRepresentable]) {
		let xpc_array = xpc_array_create(nil, 0)
		for value in array {
			xpc_array_append_value(xpc_array, XPCObject(value).object)
		}
		self = .xpcArray(xpc_array)
	}

	public init(_ dictionary: [String:XPCRepresentable]) {
		let xpc_dictionary = xpc_dictionary_create(nil, nil, 0)
		for (key, value) in dictionary {
			key.withCString { xpc_dictionary_set_value(xpc_dictionary, $0, XPCObject(value).object) }
		}
		self = .xpcDictionary(xpc_dictionary)
	}

	public var object: xpc_object_t {
	switch self {
	case .xpcNull(let value):
		return value
	case .xpcBool(let value):
		return value
	case .xpcInt64(let value):
		return value
	case .xpcuInt64(let value):
		return value
	case .xpcString(let value):
		return value
	case .xpcDouble(let value):
		return value
	case .xpcData(let value):
		return value
	case .xpcArray(let value):
		return value
	case .xpcDictionary(let value):
		return value
	case .xpcDate(let value):
		return value
	case .xpcFileHandle(let value):
		return value
	case .xpcuuid(let value):
		return value
	case .unknown(let value):
		return value
	}
	}
}

// MARK: - Printing

extension XPCObject: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return object.description
	}

	public var debugDescription: String {
		return description
	}
}

// MARK: - Equatable

public func ==(lhs: XPCObject, rhs: XPCObject) -> Bool {
	return xpc_equal(lhs.object, rhs.object)
}

// MARK: - Hashable

extension XPCObject: Hashable {
	public var hashValue: Int {
		return xpc_hash(object)
	}
}

// MARK: - Literals

extension XPCObject: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self.init(NSNull())
	}
}

extension XPCObject: ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: BooleanLiteralType) {
		self.init(value)
	}
}

extension XPCObject: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: IntegerLiteralType) {
		self.init(Int64(value))
	}
}

extension XPCObject: ExpressibleByFloatLiteral {
	public init(floatLiteral value: FloatLiteralType) {
		self.init(value)
	}
}

extension XPCObject: ExpressibleByStringLiteral {
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

extension XPCObject: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: XPCRepresentable...) {
		self.init(elements)
	}
}

extension XPCObject: ExpressibleByDictionaryLiteral {
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
			case .xpcNull:
				return NSNull()
			default:
				return nil
			}
		}
	}

	public var bool: Bool? {
		get {
			switch self {
			case .xpcBool(let value):
				return xpc_bool_get_value(value)
			default:
				return nil
			}
		}
	}

	public var int64: Int64? {
		get {
			switch self {
			case .xpcInt64(let value):
				return xpc_int64_get_value(value)
			default:
				return nil
			}
		}
	}

	public var uint64: UInt64? {
		get {
			switch self {
			case .xpcuInt64(let value):
				return xpc_uint64_get_value(value)
			default:
				return nil
			}
		}
	}

	public var string: String? {
		get {
			switch self {
			case .xpcString(let value):
				if let cString = xpc_string_get_string_ptr(value) {
					return String(cString: cString)
				} else {
					return nil
				}
			default:
				return nil
			}
		}
	}

	public var double: Double? {
		get {
			switch self {
			case .xpcDouble(let value):
				return xpc_double_get_value(value)
			default:
				return nil
			}
		}
	}

	public var data: Data? {
		get {
			switch self {
			case .xpcData(let value):
				if let bytes = UnsafeRawPointer(xpc_data_get_bytes_ptr(value)) {
					return Data(bytes: bytes, count: xpc_data_get_length(value))
				} else {
					return nil
				}
			default:
				return nil
			}
		}
	}

	public var array: [XPCObject]? {
		get {
			switch self {
			case .xpcArray(let value):
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
			case .xpcDictionary(let value):
				var result = [String:XPCObject]()
				xpc_dictionary_apply(value) { (key, value) -> Bool in
					if let key = String(validatingUTF8: key) {
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

	public var date: Date? {
		get {
			switch self {
			case .xpcDate(let value):
				return Date(timeIntervalSince1970: TimeInterval(xpc_date_get_value(value)) / xpcDateInterval)
			default:
				return nil
			}
		}
	}

	public var fileHandle: FileHandle? {
		get {
			switch self {
			case .xpcFileHandle(let value):
				return FileHandle(fileDescriptor: xpc_fd_dup(value), closeOnDealloc: true)
			default:
				return nil
			}
		}
	}

	public var uuid: UUID? {
		get {
			switch self {
			case .xpcuuid(let value):
				return (NSUUID(uuidBytes: xpc_uuid_get_bytes(value)) as UUID)
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
