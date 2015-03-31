# XPCSwift

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
platform :osx, '10.9'
pod 'SMJobKit', '~> 0.0.2'
```

## Requirements

Swift requires at least OS X 10.9. Therefore, this is also the minimum target version for XPCSwift.

XPCSwift uses Swift 1.2, i.e. it requires Xcode 6.3 or higher.
