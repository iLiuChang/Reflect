//
//  ViewController.swift
//  Reflecter
//
//  Created by LC on 2022/8/15.
//

import UIKit

class ViewController: UIViewController {

    struct Person: DictionaryReflectable {
        let name: String
        let age: Int
        let stature: Int
        let pId: Int
        
        func willUpdateValue(_ value: Any, forKey key: String) -> (String, Any?)? {
            if (key == "name") { // modify value
                return (key, "jack")
            } else if (key == "pId") { // modify key
                return ("id", value)
            } else if (key == "stature") { // blacklist
                return nil
            }
            return nil
        }
    }

    // enum
    enum Grade: AssociatedValueReflectable {
        case one
        case two
        
        var associatedValue: Any {
            switch self {
            case .one:
                return 1
            case .two:
                return "two"
            }
        }
    }
    
    class ClassPerson: DictionaryReflectable {
        var name: String?
        var age: Int?
        var stature: Int?
    }


    class Student: ClassPerson {
        var grade: Grade?
    }

    class School: DictionaryReflectable {
        var students: [String: Student]?
        var name: String?
        var schoolmaster: Person?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
//        let person = Person(name: "liuchang", age: 30, stature: 175, pId: 1)
//        let dict = person.transformToDictionary()
//        print(dict)
        // Do any additional setup after loading the view.
        
        let school = School()
        school.name = "Peking University"
        
        let person = Student()
        person.name = "jack"
        person.age = 23
        person.stature = 180
        person.grade = .two

        let person2 = Student()
        person2.name = "zhang"
        person2.age = 25
        person2.stature = 182
        person2.grade = .one
        
        school.students = ["jack":person, "zhang":person2]
        
        let person3 = ClassPerson()
        person3.name = "liu"
        person3.age = 50
        
        school.schoolmaster = Person(name: "liu", age: 50, stature: 175, pId: 1)
        
        let dict = school.transformToDictionary()

        print(dict)
    }

}

