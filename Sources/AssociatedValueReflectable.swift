//
//  AssociatedValueReflectable.swift
//  Reflect (https://github.com/iLiuChang/Reflect)
//
//  Created by LiuChang on 2022/8/15.
//  Copyright © 2022 LiuChang. All rights reserved.
//

import Foundation

/// A value that can be stored in a reflected dictionary.
///
/// The default implementation returns `self`. Collections export each element.
/// `Date`, `URL`, `UUID`, `Data`, and `Decimal` are not conformed here; adopt
/// the protocol in the client module and choose their representation there.
public protocol AssociatedValueReflectable {
    /// Representation written into the dictionary.
    var associatedValue: Any { get }
}

// MARK: - Defaults

public extension AssociatedValueReflectable {
    /// Default: the value itself. Basic types only need to declare conformance.
    var associatedValue: Any { return self }
}

/// `RawRepresentable` types (e.g. `enum Gender: Int`) only need to declare conformance:
/// ```
/// enum Gender: Int, AssociatedValueReflectable { case male, female }
/// ```
public extension AssociatedValueReflectable where Self: RawRepresentable, RawValue: AssociatedValueReflectable {
    var associatedValue: Any { return rawValue.associatedValue }
}

// MARK: - Collections

extension Array: AssociatedValueReflectable where Element: AssociatedValueReflectable {
    /// Element order is preserved. `nil` elements are omitted.
    public var associatedValue: Any { return compactMap(ReflectExport.omittingNil) }
}

extension Set: AssociatedValueReflectable where Element: AssociatedValueReflectable {
    /// `Set` has no order, so the resulting array order is not stable. `nil` elements are omitted.
    public var associatedValue: Any { return compactMap(ReflectExport.omittingNil) }
}

extension Dictionary: AssociatedValueReflectable where Value: AssociatedValueReflectable {
    /// Keys stay as declared. A `nil` value is removed instead of being written as `NSNull`.
    public var associatedValue: Any {
        var exported: [Key: Any] = [:]
        exported.reserveCapacity(count)
        for (key, value) in self {
            if let exportedValue = ReflectExport.omittingNil(value) {
                exported[key] = exportedValue
            }
        }
        return exported
    }
}

// MARK: - Optional

/// Lets `DictionaryReflectable` cheaply detect `nil` without creating a `Mirror`.
protocol NilCheckable {
    var isNil: Bool { get }
}

extension Optional: NilCheckable {
    var isNil: Bool { return self == nil }
}

extension Optional: AssociatedValueReflectable where Wrapped: AssociatedValueReflectable {
    /// Exports the wrapped value. Models and collections skip `nil` before reading this property.
    public var associatedValue: Any {
        switch self {
        case .some(let value): return value.associatedValue
        case .none: return NSNull()
        }
    }
}

enum ReflectExport {
    /// Drops `nil`. `associatedValue` of a nil optional is `NSNull`, so callers must check first.
    static func omittingNil(_ value: AssociatedValueReflectable) -> Any? {
        if let optional = value as? NilCheckable, optional.isNil {
            return nil
        }
        return value.associatedValue
    }
}

// MARK: - Basic types
// Numbers, String, Bool, and CGFloat export themselves through the default implementation.

extension Int: AssociatedValueReflectable {}
extension Int8: AssociatedValueReflectable {}
extension Int16: AssociatedValueReflectable {}
extension Int32: AssociatedValueReflectable {}
extension Int64: AssociatedValueReflectable {}
extension UInt: AssociatedValueReflectable {}
extension UInt8: AssociatedValueReflectable {}
extension UInt16: AssociatedValueReflectable {}
extension UInt32: AssociatedValueReflectable {}
extension UInt64: AssociatedValueReflectable {}
extension Double: AssociatedValueReflectable {}
extension Float: AssociatedValueReflectable {}
extension CGFloat: AssociatedValueReflectable {}
extension String: AssociatedValueReflectable {}
extension Bool: AssociatedValueReflectable {}

