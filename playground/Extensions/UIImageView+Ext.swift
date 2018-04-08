//
//  UIImageView+Ext.swift
//  playground
//
//  Created by dsxs on 2018/4/6.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIImageView{
    static var lastTaskIDKey = "dataTask"
    var lastTaskID:Int? {
        get{
            return objc_getAssociatedObject(self, &UIImageView.lastTaskIDKey) as? Int
        }
        set{
            if let task = newValue{
                objc_setAssociatedObject(self, &UIImageView.lastTaskIDKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    func setImage(from url: String, completed cb:(()->Void)?=nil) {
        guard let u = URL(string: url) else{ return }
        let indicator = UIActivityIndicatorView()
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        indicator.addConstraints([
            NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150),
            NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: indicator, attribute: .width, multiplier: 1, constant: 0),
        ])
        indicator.startAnimating()
        var task:URLSessionDataTask!
        task = URLSession.shared.dataTask(with: u) { data, resp, err in
//            print("this:", task.hashValue, "last:", self.lastTaskID)
            if let e = err{
                print(e)
            }else if let d = data,
                     let lastID = self.lastTaskID,
                     let t = task,
                     lastID == t.hashValue{
                let img = UIImage(data: d)
                DispatchQueue.main.async {
                    self.image = img
                    cb?()
                }
            }
            DispatchQueue.main.async {
                indicator.removeFromSuperview()
            }
            task = nil
        }
        lastTaskID = task.hashValue
//        print("dispatched:", lastTaskID)
        DispatchQueue.global().async{
            task.resume()
        }
    }
}
