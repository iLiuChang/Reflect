//
//  DictionaryReflectable.swift
//  Reflect (https://github.com/iLiuChang/Reflect)
//
//  Created by LiuChang on 2022/8/12.
//  Copyright © 2022 LiuChang. All rights reserved.
//

import Foundation

public protocol DictionaryReflectable: AssociatedValueReflectable {
    
    /// Returns the Dictionary.
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
       
    /// If the default model-to-dictionary transform does not fit to your model, implement
    /// this method to do additional process.
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
    /// If return `nil` will use default value.
    ///
    func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)?
}

public extension DictionaryReflectable {
    
    var associatedValue: Any {
        let mirror = Mirror(reflecting: self)
        return mapDictionary(mirror: mirror)
    }

    func reflectToDictionary() -> [String: Any] {
        if let value = associatedValue as? [String: Any] {
            return value
        }
        return [String: Any]()
    }

    func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
        return nil
    }
    
    private func mapDictionary(mirror: Mirror) -> [String: Any] {
        var result = [String: Any]()
        for child in mirror.children {
            guard let key = child.label else {
                continue
            }
            if let value = child.value as? AssociatedValueReflectable {
                if let (k, v) = willUpdateValue(value, forKey: key), !k.isEmpty {
                    if let realValue = v {
                        result[k] = realValue
                    }
                } else {
                    result[key] = value.associatedValue
                }
            } else {
                continue
            }
        }
        if let superMirror = mirror.superclassMirror {
            let superDic = mapDictionary(mirror: superMirror)
            result = result.union(superDic)
        }
        return result
    }
}

private extension Dictionary {
    
    func union(_ dictionaries: Dictionary...) -> Dictionary {
        var result = self
        dictionaries.forEach { (dictionary) -> Void in
            dictionary.forEach { (key, value) -> Void in
                result[key] = value
            }
        }
        return result
    }
}


