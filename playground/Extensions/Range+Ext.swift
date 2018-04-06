//
//  Range+Ext.swift
//  playground
//
//  Created by dsxs on 2018/4/6.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import Foundation

extension CountableRange where Bound == Int{
    var random: Int {
        get{
            var offset = 0
            if (lowerBound as Int) < 0 { // allow negative ranges
                offset = abs(lowerBound as Int)
            }
            let mini = UInt32(lowerBound as Int + offset)
            let maxi = UInt32(upperBound as Int + offset)
            return Int(mini + arc4random_uniform(maxi - mini)) - offset
        }
    }
}
