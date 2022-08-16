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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let person = Person(name: "liuchang", age: 30, stature: 175, pId: 1)
        let dict = person.transformToDictionary()
        print(dict)
        // Do any additional setup after loading the view.
    }

}

