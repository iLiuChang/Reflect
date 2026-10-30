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
    /// Element order is preserved. A `nil` element becomes `NSNull`.
    public var associatedValue: Any { return map { $0.associatedValue } }
}

extension Set: AssociatedValueReflectable where Element: AssociatedValueReflectable {
    /// `Set` has no order, so the resulting array order is not stable.
    public var associatedValue: Any { return map { $0.associatedValue } }
}

extension Dictionary: AssociatedValueReflectable where Value: AssociatedValueReflectable {
    /// Keys stay as declared. A `nil` value becomes `NSNull` rather than being removed.
    public var associatedValue: Any { return mapValues { $0.associatedValue } }
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
    /// `nil` becomes `NSNull()` (e.g. inside arrays); `DictionaryReflectable` skips nil properties.
    public var associatedValue: Any {
        switch self {
        case .some(let value): return value.associatedValue
        case .none: return NSNull()
        }
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

