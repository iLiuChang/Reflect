//
//  ClassTests.swift
//  ReflecterTests
//
//  Created by LC on 2022/8/16.
//

import XCTest

class ClassTests: XCTestCase {

    class Person: DictionaryReflectable {
        var name: String?
        var age: Int?
        var stature: Int?
    }

    func testNonNilOptionalProperties() {
        let person = Person()
        person.name = "jack"
        person.age = 18
        person.stature = 180
        let dict = person.reflectToDictionary()
        XCTAssertEqual(dict["name"] as? String, "jack")
        XCTAssertEqual(dict["age"] as? Int, 18)
        XCTAssertEqual(dict["stature"] as? Int, 180)
    }

    func testNilOptionalPropertyIsOmitted() {
        let person = Person()
        person.name = "jack"
        let dict = person.reflectToDictionary()
        XCTAssertEqual(dict["name"] as? String, "jack")
        XCTAssertNil(dict["age"])
        XCTAssertNil(dict["stature"])
    }

    class Student: Person {
        var grade: Int?
    }

    func testInheritedStoredProperties() {
        let student = Student()
        student.name = "jack"
        student.age = 18
        student.stature = 180
        student.grade = 2
        let dict = student.reflectToDictionary()
        XCTAssertEqual(dict["name"] as? String, "jack")
        XCTAssertEqual(dict["age"] as? Int, 18)
        XCTAssertEqual(dict["stature"] as? Int, 180)
        XCTAssertEqual(dict["grade"] as? Int, 2)
    }

    class School: DictionaryReflectable {
        var students: [Student]?
        var name: String?
    }

    func testArrayOfModels() throws {
        let school = School()
        school.name = "Peking University"

        let jack = Student()
        jack.name = "jack"
        jack.age = 23
        jack.stature = 180
        jack.grade = 2

        let zhang = Student()
        zhang.name = "zhang"
        zhang.age = 25
        zhang.stature = 182
        zhang.grade = 3

        school.students = [jack, zhang]
        let dict = school.reflectToDictionary()
        XCTAssertEqual(dict["name"] as? String, "Peking University")

        let students = try XCTUnwrap(dict["students"] as? [[String: Any]])
        XCTAssertEqual(students.count, 2)
        XCTAssertEqual(students[0]["name"] as? String, "jack")
        XCTAssertEqual(students[0]["age"] as? Int, 23)
        XCTAssertEqual(students[0]["stature"] as? Int, 180)
        XCTAssertEqual(students[0]["grade"] as? Int, 2)
        XCTAssertEqual(students[1]["name"] as? String, "zhang")
        XCTAssertEqual(students[1]["grade"] as? Int, 3)
    }

    class Parent: DictionaryReflectable {
        var id: Int = 1

        func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
            if key == "name" {
                return ("id", value)
            }
            return nil
        }
    }

    class Child: Parent {
        var name: String = "child"
    }

    func testSubclassValueReplacesSuperclassKey() {
        let dict = Child().reflectToDictionary()
        XCTAssertEqual(dict["id"] as? String, "child")
        XCTAssertNil(dict["name"])
    }
}
