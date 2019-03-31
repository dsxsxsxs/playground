//
//  ChatViewCell.swift
//  playground
//
//  Created by dsxs on 2019/03/30.
//  Copyright © 2019 dsxs. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {
    @IBOutlet weak var message: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ChatViewOwnCell: UITableViewCell {
    @IBOutlet weak var message: UITextView!
}

extension UITableView {
    func register<Cell: UITableViewCell>(_ cellType: Cell.Type) {
        let nibName = String(describing: cellType)
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
        } else {
            register(cellType, forCellReuseIdentifier: nibName)
        }
    }
    
    func register<View: UITableViewHeaderFooterView>(_ viewType: View.Type) {
        let nibName = String(describing: viewType)
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            register(UINib(nibName: nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: nibName)
        } else {
            register(viewType, forHeaderFooterViewReuseIdentifier: nibName)
        }
    }
    
    func dequeueReusableHeaderFooterView<View: UITableViewHeaderFooterView>(with viewType: View.Type) -> View {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: viewType)) as! View
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(with cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withIdentifier: String(describing: cellType), for: indexPath) as! Cell
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(with cellType: Cell.Type) -> Cell {
        return dequeueReusableCell(withIdentifier: String(describing: cellType)) as! Cell
    }
}
