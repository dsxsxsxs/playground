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
    static var imageTaskGroup = DispatchGroup()
    var lastTask:URLSessionDataTask? {
        get{
            return objc_getAssociatedObject(self, "dataTask") as? URLSessionDataTask
        }
        set{
            if let task = newValue{
                objc_setAssociatedObject(self, "dataTask", task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }else{
                objc_setAssociatedObject(self, "dataTask", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    func setImage(from url: String, completed cb:(()->Void)?=nil) {
        guard let u = URL(string: url) else{ return }
        lastTask?.cancel()
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
        lastTask = URLSession(configuration: .default).dataTask(with: u) {[weak self] data, resp, err in
            if let e = err{
                print(e)
            }else if let d = data{
                let img = UIImage(data: d)
                DispatchQueue.main.async {
                    self?.image = img
                    indicator.removeFromSuperview()
                    cb?()
                }
            }
        }
        DispatchQueue.global().async(group: UIImageView.imageTaskGroup){ [weak lastTask] in
            lastTask?.resume()
        }
    }
}
