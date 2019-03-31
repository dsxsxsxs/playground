//
//  MessageInputView.swift
//  playground
//
//  Created by dsxs on 2019/03/30.
//  Copyright © 2019 dsxs. All rights reserved.
//

import UIKit

class MessageInputView: UIView {
    @IBOutlet weak var textField: UITextField!
    
    var onNewMessage: ((String) ->Void)? {
        didSet {
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        textField.text = nil
        onNewMessage?(text)
    }
}
