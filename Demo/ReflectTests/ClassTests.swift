//
//  ClassTests.swift
//  ReflecterTests
//
//  Created by LC on 2022/8/16.
//

import XCTest

class ClassTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    class ClassPerson: DictionaryReflectable {
        var name: String?
        var age: Int?
        var stature: Int?
    }

    func testExample() throws {
        let person = ClassPerson()
        person.name = "jack"
        person.age = 18
        person.stature = 180
        let dict = person.reflectToDictionary()
        XCTAssert(dict["name"] as! String == "jack")
        XCTAssert(dict["age"] as! Int == 18)
        XCTAssert(dict["stature"] as! Int == 180)
    }

    class Student: ClassPerson {
        var grade: Int?
    }
    
    func testExample2() throws {
        let person = Student()
        person.name = "jack"
        person.age = 18
        person.stature = 180
        person.grade = 2
        let dict = person.reflectToDictionary()
        XCTAssert(dict["name"] as! String == "jack")
        XCTAssert(dict["age"] as! Int == 18)
        XCTAssert(dict["stature"] as! Int == 180)
        XCTAssert(dict["grade"] as! Int == 2)
    }

    class School: DictionaryReflectable {
        var students: [Student]?
        var name: String?
    }
    
    func testArray() throws {
        let school = School()
        school.name = "Peking University"
        
        let person = Student()
        person.name = "jack"
        person.age = 23
        person.stature = 180
        person.grade = 2

        let person2 = Student()
        person2.name = "zhang"
        person2.age = 25
        person2.stature = 182
        person2.grade = 3
        
        school.students = [person, person2]
        
        let dict = school.reflectToDictionary()
        
        XCTAssert(dict["name"] as! String == "Peking University")

        let p1 = (dict["students"] as! Array<Dictionary<String, Any>>).first!
        
        XCTAssert(p1["name"] as! String == "jack")
        XCTAssert(p1["age"] as! Int == 23)
        XCTAssert(p1["stature"] as! Int == 180)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
