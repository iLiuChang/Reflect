//
//  DictionaryReflectable.swift
//  Reflect (https://github.com/iLiuChang/Reflect)
//
//  Created by LiuChang on 2022/8/12.
//  Copyright © 2022 LiuChang. All rights reserved.
//

import Foundation

public protocol DictionaryReflectable: AssociatedValueReflectable {
    
    func reflectToDictionary() -> [String: Any]
        
    func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)?
}

public extension DictionaryReflectable {
    
    func reflectToDictionary() -> [String: Any] {
        if let value = associatedValue as? [String: Any] {
            return value
        }
        return [String: Any]()
    }

    var associatedValue: Any {
        let mirror = Mirror(reflecting: self)
        return mapDictionary(mirror: mirror)
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


