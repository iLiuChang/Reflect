//
//  StructTests.swift
//  ReflecterTests
//
//  Created by LC on 2022/8/16.
//

import XCTest
import Foundation
import CoreGraphics

class StructTests: XCTestCase {

    struct Person: DictionaryReflectable {
        let name: String
        let age: Int
        let stature: Int
        private let secret: String = "hidden"
        var title: String { name }
    }

    func testStoredProperties() {
        let dict = Person(name: "liuchang", age: 30, stature: 175).reflectToDictionary()
        XCTAssertEqual(dict["name"] as? String, "liuchang")
        XCTAssertEqual(dict["age"] as? Int, 30)
        XCTAssertEqual(dict["stature"] as? Int, 175)
        XCTAssertEqual(dict["secret"] as? String, "hidden")
        XCTAssertNil(dict["title"])
    }

    func testZeroFalseAndEmptyStringAreKept() {
        struct Value: DictionaryReflectable {
            let count: Int
            let enabled: Bool
            let note: String
            let width: CGFloat
        }
        let dict = Value(count: 0, enabled: false, note: "", width: 12.5).reflectToDictionary()
        XCTAssertEqual(dict["count"] as? Int, 0)
        XCTAssertEqual(dict["enabled"] as? Bool, false)
        XCTAssertEqual(dict["note"] as? String, "")
        XCTAssertEqual(dict["width"] as? CGFloat, 12.5)
    }

    func testCGFloatIsPreserved() {
        struct Size: DictionaryReflectable {
            let width: CGFloat
        }
        let dict = Size(width: 12.5).reflectToDictionary()
        XCTAssertEqual(dict["width"] as? CGFloat, 12.5)
    }

    struct Nested: DictionaryReflectable {
        let title: String
        let person: Person
    }

    func testNestedModelBecomesDictionary() throws {
        let dict = Nested(title: "profile", person: Person(name: "ann", age: 20, stature: 160)).reflectToDictionary()
        XCTAssertEqual(dict["title"] as? String, "profile")
        let person = try XCTUnwrap(dict["person"] as? [String: Any])
        XCTAssertEqual(person["name"] as? String, "ann")
        XCTAssertEqual(person["age"] as? Int, 20)
    }

    struct TunedPerson: DictionaryReflectable {
        let name: String
        let age: Int
        let stature: Int
        let pId: Int
        let friend: Person

        func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
            if key == "name" { return (key, "jack") }
            if key == "pId" { return ("id", value) }
            if key == "stature" { return (key, nil) }
            if key == "friend" { return ("user", value) }
            return nil
        }
    }

    func testWillUpdateValueStoresReturnedValueAsGiven() {
        let friend = Person(name: "ann", age: 20, stature: 160)
        let dict = TunedPerson(name: "liuchang", age: 30, stature: 175, pId: 1, friend: friend).reflectToDictionary()
        XCTAssertEqual(dict["name"] as? String, "jack")
        XCTAssertEqual(dict["age"] as? Int, 30)
        XCTAssertEqual(dict["id"] as? Int, 1)
        XCTAssertNil(dict["pId"])
        XCTAssertNil(dict["stature"])
        XCTAssertTrue(dict["user"] is Person)
        XCTAssertEqual((dict["user"] as? Person)?.name, "ann")
    }

    struct Box: DictionaryReflectable {
        let name: String?
        let items: [String?]
        let flags: [String: String?]
        let scores: [Int: String]
        let tags: Set<String>
        let created: Date
        let page: URL
        let token: UUID
        let payload: Data
        let price: Decimal
    }

    func testCollectionsAndSkippedTypes() throws {
        let dict = Box(
            name: nil,
            items: ["a", nil, "b"],
            flags: ["on": "yes", "off": nil],
            scores: [2: "two", 1: "one"],
            tags: ["b", "a"],
            created: Date(timeIntervalSince1970: 0),
            page: URL(string: "https://example.com")!,
            token: UUID(),
            payload: Data([1, 2]),
            price: Decimal(105) / Decimal(10)
        ).reflectToDictionary()

        XCTAssertNil(dict["name"])
        XCTAssertEqual(dict["items"] as? [String], ["a", "b"])

        let flags = try XCTUnwrap(dict["flags"] as? [String: Any])
        XCTAssertEqual(flags["on"] as? String, "yes")
        XCTAssertNil(flags["off"])

        let scores = try XCTUnwrap(dict["scores"] as? [Int: Any])
        XCTAssertEqual(scores[1] as? String, "one")
        XCTAssertEqual(scores[2] as? String, "two")

        let tags = try XCTUnwrap(dict["tags"] as? [String])
        XCTAssertEqual(Set(tags), ["a", "b"])

        XCTAssertNil(dict["created"])
        XCTAssertNil(dict["page"])
        XCTAssertNil(dict["token"])
        XCTAssertNil(dict["payload"])
        XCTAssertNil(dict["price"])
    }

    struct NullName: DictionaryReflectable {
        let name: String?

        func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
            if key == "name" {
                return (key, NSNull())
            }
            return nil
        }
    }

    func testNilPropertyBecomesNSNullOnlyWhenRequested() {
        let dict = NullName(name: nil).reflectToDictionary()
        XCTAssertTrue(dict["name"] is NSNull)
    }

    enum RawColor: Int, AssociatedValueReflectable {
        case red = 2
    }

    enum Kind {
        case left
    }

    struct EnumBox: DictionaryReflectable {
        let color: RawColor
        let kind: Kind
    }

    func testOnlyConformingRawEnumsAreExported() {
        let dict = EnumBox(color: .red, kind: .left).reflectToDictionary()
        XCTAssertEqual(dict["color"] as? Int, 2)
        XCTAssertNil(dict["kind"])
    }

    struct Money: AssociatedValueReflectable {
        let amount: Decimal
        var associatedValue: Any { "10.5" }
    }

    struct Receipt: DictionaryReflectable {
        let total: Money
    }

    struct Event: DictionaryReflectable {
        let created: Date

        func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
            guard key == "created", value is Date else { return nil }
            return ("createdAt", "1970-01-01T00:00:00Z")
        }
    }

    func testNonConformingPropertyCanBeCustomized() {
        let unused = Date(timeIntervalSince1970: 0)
        let dict = Event(created: unused).reflectToDictionary()
        XCTAssertNil(dict["created"])
        XCTAssertEqual(dict["createdAt"] as? String, "1970-01-01T00:00:00Z")
    }

    func testCustomAssociatedValue() {
        let dict = Receipt(total: Money(amount: Decimal(105) / Decimal(10))).reflectToDictionary()
        XCTAssertEqual(dict["total"] as? String, "10.5")
    }
}
