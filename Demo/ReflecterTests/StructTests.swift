//
//  StructTests.swift
//  ReflecterTests
//
//  Created by LC on 2022/8/16.
//

import XCTest

class StructTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct StructPerson: DictionaryReflectable {
        let name: String
        let age: Int
        let stature: Int
    }

    func testStruct() throws {
        let person = StructPerson(name: "liuchang", age: 30, stature: 175)
        let dict = person.transformToDictionary()
        XCTAssert(dict["name"] as! String == "liuchang")
        XCTAssert(dict["age"] as! Int == 30)
        XCTAssert(dict["stature"] as! Int == 175)
    }


}
