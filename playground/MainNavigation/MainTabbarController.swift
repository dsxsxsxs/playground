//
//  MainTabbarController.swift
//  playground
//
//  Created by dsxs on 2018/4/6.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    lazy var mainNavigationController:UINavigationController? = { [unowned self] in
        return UINavigationController(rootViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tab1 = RandomImageViewController()
        tab1.tabBarItem.title = "RI"
        let tab2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        tab2.tabBarItem.title = "VC"
        setViewControllers([tab1, tab2], animated: false)

    }
    
    
}
