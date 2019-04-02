//
//  UIImage+Ext.swift
//  playground
//
//  Created by dsxs on 2018/4/6.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import UIKit

protocol StoryboardInstantiatable {

}
extension StoryboardInstantiatable where Self: UINavigationController {
    init(rootViewControllerType: UIViewController.Type, identifier: String? = nil) {
        if let id = identifier {
            self = UIStoryboard(name: String(describing: rootViewControllerType), bundle: Bundle(for: rootViewControllerType)).instantiateViewController(withIdentifier: id) as! Self
            return
        }
        self = UIStoryboard(name: String(describing: rootViewControllerType), bundle: Bundle(for: rootViewControllerType)).instantiateInitialViewController() as! Self
    }
}
extension StoryboardInstantiatable where Self: UIViewController {
    init(name: String? = nil, bundle: Bundle? = nil, identifier: String) {
        let n = name ?? String(describing: Self.self)
        let b = bundle ?? Bundle(for: Self.self)
        guard identifier.isEmpty else {
            self = UIStoryboard(name: n, bundle: b).instantiateViewController(withIdentifier: identifier) as! Self
            return
        }
        self = UIStoryboard(name: n, bundle: b).instantiateInitialViewController() as! Self
    }
}


protocol NibInitializable {
    
}

extension NibInitializable where Self: UIView {
    init(owner: Any?, options: [UINib.OptionsKey : Any]? = nil) {
        self = Bundle(for: Self.self).loadNibNamed(String(describing: Self.self), owner: owner, options: options)?[0] as! Self
    }
}

extension UIView: NibInitializable {
}

extension UIImage {
    
    class func image(with color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    var pngBase64Encoded:String?{
        let data = self.pngData()
        return data?.base64EncodedString(options: .lineLength64Characters)
    }
}
