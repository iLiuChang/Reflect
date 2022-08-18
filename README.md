# Reflect
Model to Dictionary in Swift.

## Requirements

- **iOS 10.0+**
- **Swift 4.0+**

## Usage

```swift
struct Person: DictionaryReflectable {
    let name: String
    let age: Int
    let stature: Int
}

let person = Person(name: "liuchang", age: 30, stature: 175)
let dict = person.reflectToDictionary()
print(dict) // ["age": 30, "name": "liuchang", "stature": 175]
```



## Installation

### CocoaPods

To integrate Reflect into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Reflect'
```

### Manual

1. Download everything in the Reflect folder;
2. Add (drag and drop) the source files in Reflect to your project.

## License

Reflect is provided under the MIT license. See LICENSE file for details.
