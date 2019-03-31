//
//  UIImage+Ext.swift
//  playground
//
//  Created by dsxs on 2018/4/6.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import UIKit

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
