//
//  RandomImageViewController.swift
//  playground
//
//  Created by dsxs on 2018/4/6.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import UIKit

class RandomImageViewController: UITableViewController{
    let cellID = String(describing: RandomImageViewCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! RandomImageViewCell
        let url = "https://picsum.photos/350/\((350..<350).random)/?image=\(indexPath.row)"
        cell.img.setImage(from: url){
            
        }
        cell.lbl.text = url
        return cell
    }
}
