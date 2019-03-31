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
        let tab1 = UINavigationController(rootViewController: RandomImageViewController())
        tab1.tabBarItem.title = "RI"
        let tab2 = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController"))
        tab2.tabBarItem.title = "VC"
        let tab3 = UINavigationController(rootViewController: ChatViewController())
        tab3.tabBarItem.title = "RI"

        setViewControllers([tab1, tab2, tab3], animated: false)

    }
    
    
}
