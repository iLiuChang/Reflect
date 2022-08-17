//
//  ReflectTests.swift
//  ReflectTests
//
//  Created by 刘畅 on 2022/8/17.
//

import XCTest
@testable import Reflect

class ReflectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct Person: DictionaryReflectable {
        let name: String
        let age: Int
        let stature: Int
    }

    func testPerformanceExample() throws {
        let person = Person(name: "liuchang", age: 30, stature: 175)
        self.measure {
            (0..<10000).forEach { _ in
                let _ = person.reflectToDictionary()
            }
        }
    }

    struct EncodablePerson: Encodable {
        let name: String
        let age: Int
        let stature: Int
    }

    func testPerformanceEncodablePerson() throws {
        let person = EncodablePerson(name: "liuchang", age: 30, stature: 175)
        self.measure {
            (0..<10000).forEach { _ in
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(person)
                    let _ = try JSONSerialization.jsonObject(with: data, options: [])
                } catch {
                }
            }
        }
    }


}
