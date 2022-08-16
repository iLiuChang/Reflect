//
//  AssociatedValueReflectable.swift
//  Reflecter (https://github.com/iLiuChang/Reflecter)
//
//  Created by LiuChang on 2022/8/15.
//  Copyright © 2022 LiuChang. All rights reserved.
//

import Foundation

public protocol AssociatedValueReflectable {
    var associatedValue: Any { get }
}

extension Array: AssociatedValueReflectable where Element: AssociatedValueReflectable {
    public var associatedValue: Any { return map { $0.associatedValue } }
}

extension Set: AssociatedValueReflectable where Element: AssociatedValueReflectable {
    public var associatedValue: Any { return map { $0.associatedValue } }
}

extension Dictionary: AssociatedValueReflectable where Value: AssociatedValueReflectable {
    public var associatedValue: Any { return mapValues { $0.associatedValue } }
}

extension Int8: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension Int16: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension Int32: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension Int: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension UInt16: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension UInt32: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension UInt: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension Double: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension Float: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension String: AssociatedValueReflectable { public var associatedValue: Any { return self } }
extension Bool: AssociatedValueReflectable { public var associatedValue: Any { return self } }
