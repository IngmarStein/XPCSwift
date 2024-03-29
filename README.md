# XPCSwift [![Travis Build Status](https://img.shields.io/travis/IngmarStein/XPCSwift.svg)](https://travis-ci.org/IngmarStein/XPCSwift)

Type safe Swift wrapper for libxpc.

## Usage

```swift
let xpcArray = XPCObject([ Int64(1234), "test" ])

println(xpcArray)
//<OS_xpc_array: <array: 0x1001d7150> { count = 2, capacity = 8, contents =
//	0: <int64: 0x1001d7430>: 1234
//	1: <string: 0x1001d78e0> { length = 4, contents = "test" }
//}>

println(xpcArray.array?[0].int64)
//Optional(1234)

println(xpcArray.array?[1].string)
//Optional("test")
```

## Podfile

```ruby
platform :osx, '10.10'
pod 'XPCSwift', '~> 0.0.7'
```

## Requirements

XPCSwift requires at least macOS 10.10. Therefore, this is also the minimum target version for XPCSwift.

XPCSwift uses Swift 5.0, i.e. it requires Xcode 10.2 or higher.
