# Reflect

![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-Apple-lightgrey.svg)
![Version](https://img.shields.io/badge/Version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-blueviolet.svg)

## Overview

Turn a Swift model into a `[String: Any]` dictionary with `Mirror`. Conform to `DictionaryReflectable` and call `reflectToDictionary()`:

- **Structs and classes** — stored properties become dictionary entries
- **Nested models** — a property that also conforms becomes a nested dictionary

## Features

- **Stored properties** — reads `struct` and `class` stored properties, including `private` ones
- **Nested models** — a `DictionaryReflectable` property is exported as `[String: Any]`
- **Collections** — `Array`, `Set`, and `Dictionary` export elements that conform to `AssociatedValueReflectable`
- **Optionals** — `nil` properties and `nil` collection elements are omitted
- **Raw enums** — declare `AssociatedValueReflectable` and the raw value is exported
- **Key and value changes** — implement `willUpdateValue(_:forKey:)` to rename a key or replace a value
- **Inheritance** — superclass properties are written first, so a subclass value replaces the same key

## Requirements

- iOS 12.0+
- macOS 10.13+
- tvOS 12.0+
- watchOS 4.0+
- visionOS 1.0+
- Swift 5.9+

## Installation

### CocoaPods

```ruby
pod 'Reflect'
```

Then run:

```bash
pod install
```

### Swift Package Manager

In Xcode: **File → Add Packages…** and enter:

```
https://github.com/iLiuChang/Reflect.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/Reflect.git", from: "2.0.0")
]
```

### Manual

1. Download the files in the `Sources` folder
2. Drag them into your Xcode project

## Usage

### Model to Dictionary

```swift
import Reflect

struct Person: DictionaryReflectable {
    let name: String
    let age: Int
    let stature: Int
}

let person = Person(name: "liuchang", age: 30, stature: 175)
let dict = person.reflectToDictionary()
print(dict) // ["age": 30, "name": "liuchang", "stature": 175]
```

`false`, `0`, and `""` are kept. Computed properties are skipped. `Date`, `URL`, `UUID`, `Data`, and `Decimal` are omitted unless `willUpdateValue` returns a value for them, or you adopt `AssociatedValueReflectable`.

### Nested Model

```swift
struct Profile: DictionaryReflectable {
    let title: String
    let person: Person
}

let dict = Profile(title: "profile", person: person).reflectToDictionary()
// dict["person"] is ["name": "liuchang", "age": 30, "stature": 175]
```

### Optional, Array, and Dictionary

A `nil` stored property is left out. `nil` elements in an `Array`, `Set`, or `Dictionary` are left out too. Dictionary keys stay as declared, so an `Int` key remains an `Int`.

```swift
struct Box: DictionaryReflectable {
    let name: String?
    let items: [String?]
    let scores: [Int: String]
}

let dict = Box(name: nil, items: ["a", nil], scores: [1: "one"]).reflectToDictionary()
// "name" is absent
// "items" is ["a"]
// "scores" is [1: "one"]
```

Return `NSNull()` from `willUpdateValue` when a `nil` property must be sent as JSON `null`:

```swift
func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
    if key == "name" {
        return (key, NSNull())
    }
    return nil
}
```

`Set` becomes an array. The array has no stable order.

### Raw Enum

```swift
enum Gender: Int, AssociatedValueReflectable {
    case male
    case female
}
```

`associatedValue` is the raw value. An enum that does not conform is skipped.

### Custom Representation

Adopt `AssociatedValueReflectable` in your module when the default value is not the one you want to store:

```swift
extension Date: AssociatedValueReflectable {
    public var associatedValue: Any {
        ISO8601DateFormatter().string(from: self)
    }
}
```

The same extension works for `URL`, `UUID`, `Data`, and `Decimal`.

### Rename, Replace, or Drop a Property

```swift
struct Person: DictionaryReflectable {
    let name: String
    let age: Int
    let stature: Int
    let pId: Int

    func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
        if key == "name" {
            return (key, "jack")
        } else if key == "pId" {
            return ("id", value)
        } else if key == "stature" {
            return (key, nil)
        }
        return nil
    }
}

let dict = person.reflectToDictionary()
// ["age": 30, "name": "jack", "id": 1]
```

Return `nil` to keep the default export. The value you return is stored as given. Return `friend.reflectToDictionary()` when a renamed nested model should still be a dictionary.

`willUpdateValue` is called for every stored property. Return `nil` and a non-conforming value, such as `Date`, stays omitted. Return a string, `NSNull()`, or any other value to write that property yourself. On a class, implement it on the class that declares `DictionaryReflectable`. A subclass method is used only when it overrides that implementation.

## API Reference

### DictionaryReflectable

| Property / Method | Description |
|---|---|
| `reflectToDictionary()` | Returns the stored properties as `[String: Any]`. |
| `willUpdateValue(_:forKey:)` | Returns `nil` to keep the default, `(key, nil)` to drop the property, or `(newKey, value)` to write `value` under `newKey`. |
| `associatedValue` | For a model, the same dictionary as `reflectToDictionary()`. |

### AssociatedValueReflectable

| Property / Method | Description |
|---|---|
| `associatedValue` | Value written into the dictionary. The default is `self`. |

These types conform and export themselves: `Int`, `Int8`, `Int16`, `Int32`, `Int64`, `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`, `Float`, `Double`, `CGFloat`, `String`, and `Bool`.

| Conformance | Export |
|---|---|
| `Array` where `Element: AssociatedValueReflectable` | An array of each element's `associatedValue`, without `nil` elements. Order is preserved. |
| `Set` where `Element: AssociatedValueReflectable` | An array of each element's `associatedValue`, without `nil` elements. Order is not stable. |
| `Dictionary` where `Value: AssociatedValueReflectable` | The same keys, with each non-`nil` value replaced by its `associatedValue`. |
| `Optional` where `Wrapped: AssociatedValueReflectable` | The wrapped `associatedValue`. `nil` is omitted. |
| `RawRepresentable` where `RawValue: AssociatedValueReflectable` | `rawValue.associatedValue`. Declare conformance on the type. |

## Architecture

`reflectToDictionary()` walks the stored properties of `Mirror(reflecting:)`. Superclass properties are collected first, then the current type's properties overwrite the same keys. Each value that conforms to `AssociatedValueReflectable` is replaced by `associatedValue`, which is how nested models and collections expand.

`willUpdateValue(_:forKey:)` sees every stored property. A returned value is inserted directly. When it returns `nil`, `nil` properties and non-conforming values are dropped. `Mirror` does not report computed properties or access level, so `private` stored properties are included and computed properties are not.

A class instance that points back to one already being exported is visited again. Reflect does not track the export stack, so a reference cycle recurses until the stack overflows.

## License

MIT License. See [LICENSE](LICENSE) for details.
