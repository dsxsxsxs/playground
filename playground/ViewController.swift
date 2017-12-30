//
//  ViewController.swift
//  playground
//
//  Created by dsxs on 2017/12/22.
//  Copyright © 2017年 dsxs. All rights reserved.
//

import UIKit

struct TestModel{
    var id = 0
    var created_at:Date = Date()
    var title = ""
    
    
}
extension TestModel:OrzModel{
    func primaryKey() -> (String, PrimaryKeyDecorator) {
        return ("id", .autoIncrement)
    }
    
    func options() -> [String : String]? {
        return nil
    }

    init?(from dictionary: [String : Any]) {
        print(dictionary)
        guard
            let i = dictionary["id"] as? Int,
            let c = dictionary["created_at"] as? Double,
            let t = dictionary["title"] as? String
            else{
                return nil
        }
        id = i
        created_at = Date(timeIntervalSince1970: c)
        title = t
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

