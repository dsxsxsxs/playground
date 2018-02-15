//
//  UIRadioButton.swift
//  playground
//
//  Created by dsxs on 2018/02/12.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import UIKit
extension UIAlertController{
    func set(vc: UIViewController, height: CGFloat? = nil) {
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
    func doPicker(_ sender: Any) {
        let alert = UIAlertController(title: "Picker View", message: "", preferredStyle: .actionSheet)
        let vc = UIViewController()
        let pickerView = UIPickerView()
        //        pickerView.delegate = self
        //        pickerView.dataSource = self
        vc.view = pickerView
        alert.set(vc: vc, height: 216)
        let action = UIAlertAction(title: "Done", style: .cancel) { _ in
            print("picked")
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

}
@IBDesignable class UIRadioButton: UIButton{
    struct Weak<T:AnyObject> {
        weak var obj:T?
    }
    static var buttonPool:[Weak<UIRadioButton>] = []
    override var buttonType: UIButtonType{
        return .custom
    }
    @IBInspectable var isChecked:Bool = false{
        willSet{
            guard newValue, !isCheckBox else{
                return
            }
            UIRadioButton.buttonPool
                .filter{ $0.obj?.id == id && ($0.obj?.isChecked ?? false) }
                .forEach{ $0.obj?.isChecked = false }
        }
        didSet{
            updateIcon()
            sendActions(for: .valueChanged)
        }
    }
    @IBInspectable var isCheckBox:Bool = false
    @IBInspectable var id:String = ""{
        didSet{
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    func initialize() {
        UIRadioButton.buttonPool.append(Weak(obj: self))
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        updateIcon()
    }
    deinit {
        guard let idx = UIRadioButton.buttonPool.index(where: { $0.obj == self }) else{
            return
        }
        UIRadioButton.buttonPool.remove(at: idx)
    }
    func updateIcon()  {
        let bundle = Bundle(for: type(of: self))
        var name:String
        if isCheckBox{
            name = isChecked ? "checked" : "unchecked"
        }else{
            name = isChecked ? "checked" : "unchecked"
        }
        setImage(UIImage(named: name, in: bundle, compatibleWith: nil) , for: .normal)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }
    @objc func tapped() {
        if isCheckBox{
            isChecked = !isChecked
            return
        }
        if isChecked{
            return
        }
        isChecked = true
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateIcon()
    }
}
