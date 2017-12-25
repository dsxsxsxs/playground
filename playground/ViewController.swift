//
//  ViewController.swift
//  playground
//
//  Created by dsxs on 2017/12/22.
//  Copyright © 2017年 dsxs. All rights reserved.
//

import UIKit

struct TestModel:OrzModel{
    var id = 0
    var created_at:Date = Date()
    var title = ""
    
    func primaryKey() -> (String, PrimaryKeyDecorator) {
        return ("id", .autoIncrement)
    }
    
    func options() -> [String : String]? {
        return nil
    }
    
    func fromDictionary(_ obj: [String : Any]) -> OrzModel? {
        var m = TestModel()
        guard
            let i = obj["id"] as? Int,
            let c = obj["created_at"] as? Date,
            let t = obj["title"] as? String
        else{
            return nil
        }
        m.id = i
        m.created_at = c
        m.title = t
        return m
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

