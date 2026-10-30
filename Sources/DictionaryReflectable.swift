//
//  DictionaryReflectable.swift
//  Reflect (https://github.com/iLiuChang/Reflect)
//
//  Created by LiuChang on 2022/8/12.
//  Copyright © 2022 LiuChang. All rights reserved.
//

import Foundation

public protocol DictionaryReflectable: AssociatedValueReflectable {
    
    /// Returns stored properties as `[String: Any]`.
    ///
    /// Nested models become dictionaries. `nil` values are omitted. A value that does not
    /// conform to `AssociatedValueReflectable` is omitted.
    ///
    /// Example:
    /// ```
    /// struct Person: DictionaryReflectable {
    ///     let name: String
    ///     let age: Int
    ///     let stature: Int
    /// }
    ///
    /// let person = Person(name: "liuchang", age: 30, stature: 175)
    /// let dict = person.reflectToDictionary()
    /// print(dict) // ["age": 30, "name": "liuchang", "stature": 175]
    /// ```
    ///
    func reflectToDictionary() -> [String: Any]
       
    /// Adjust one stored property before it is written. Every stored property is passed
    /// here, including `nil` and types that do not conform to `AssociatedValueReflectable`.
    ///
    /// Return `nil` to keep the default export. Conforming values use `associatedValue`.
    /// `nil` and non-conforming values, such as `Date`, are omitted.
    /// Return `(key, nil)` to drop that property.
    /// Return `(newKey, value)` to write `value` as given. Use this to turn a `Date` into
    /// a string, or a `nil` property into `NSNull()`, without adopting the protocol.
    /// A nested model returned here stays an object; return its dictionary when that
    /// property should still be exported.
    ///
    /// Swift installs this requirement on the class that declares `DictionaryReflectable`.
    /// A subclass implementation is used only when it `override`s a superclass implementation.
    ///
    /// Example:
    /// ```
    /// struct Person: DictionaryReflectable {
    ///     let name: String
    ///     let age: Int
    ///     let stature: Int
    ///     let pId: Int
    ///
    ///     func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
    ///         if (key == "name") { // modify value
    ///             return (key, "jack")
    ///         } else if (key == "pId") { // modify key
    ///             return ("id", value)
    ///         } else if (key == "stature") { // blacklist
    ///             return (key, nil)
    ///         }
    ///         return nil // default value
    ///     }
    /// }
    /// let person = Person(name: "liuchang", age: 30, stature: 175, pId: 1)
    /// let dict = person.reflectToDictionary()
    /// print(dict) // ["age": 30, "name": "jack", "id": 1]
    /// ```
    func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)?
}

public extension DictionaryReflectable {

    var associatedValue: Any {
        return reflectToDictionary()
    }

    func reflectToDictionary() -> [String: Any] {
        return makeDictionary(from: Mirror(reflecting: self))
    }

    func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
        return nil
    }

    /// Superclass properties are written first, so a subclass key replaces the same superclass key.
    /// `Mirror` includes every stored property, including `private` ones, and skips computed properties.
    /// Reference cycles are not detected; a child that points back at an ancestor recurses until the stack overflows.
    private func makeDictionary(from mirror: Mirror) -> [String: Any] {
        var result: [String: Any] = mirror.superclassMirror.map { makeDictionary(from: $0) } ?? [:]
        result.reserveCapacity(result.count + mirror.children.count)

        for child in mirror.children {
            guard let key = child.label else { continue }
            let raw = child.value
            if let (newKey, newValue) = willUpdateValue(raw, forKey: key), !newKey.isEmpty {
                if let newValue = newValue {
                    result[newKey] = newValue
                }
                continue
            }
            if let optional = raw as? NilCheckable, optional.isNil { continue }
            guard let value = raw as? AssociatedValueReflectable,
                  let exported = ReflectExport.omittingNil(value) else { continue }
            result[key] = exported
        }
        return result
    }
}

