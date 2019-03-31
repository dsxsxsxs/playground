//
//  ChatViewController.swift
//  playground
//
//  Created by dsxs on 2019/03/30.
//  Copyright © 2019 dsxs. All rights reserved.
//

import UIKit

class ChatViewController: UITableViewController {
    struct Message {
        var isSelf = false
        var text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis"
    }
    weak var table: UITableView!
    override var tableView: UITableView! {
        get {
            return table ?? super.tableView
        }
        set {
            let v = view
            super.tableView = newValue
            table = newValue
            view = v
        }
    }
    
    lazy var messages: [Message] = {
        return [Message](repeating: Message(), count: 20)
    }()
    
    override func loadView() {
        super.loadView()
        let view = UIView()
        let table: UITableView! = tableView
        self.view = view
        tableView = table
        let messageInput = MessageInputView(owner: nil)
        view.addSubview(table)
        view.addSubview(messageInput)
        messageInput.onNewMessage = { [weak self] in self?.sendMessage(text: $0) }
        view.backgroundColor = .white
//        let size = messageInput.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
//        print(size)
        messageInput.translatesAutoresizingMaskIntoConstraints = false
        table.translatesAutoresizingMaskIntoConstraints = false
        table.constriant(attribute: .top)(.equal)(view)(.top)
        table.attach(to: view)(.equal)([.top, .leading, .trailing])
        view.addConstraints([
            NSLayoutConstraint(item: table, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: table, attribute: .bottom, relatedBy: .equal, toItem: messageInput, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: table, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: table, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messageInput, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messageInput, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: messageInput, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(ChatViewCell.self)
        tableView.register(ChatViewOwnCell.self)
        tableView.contentInset.bottom = 60
        tableView.keyboardDismissMode = .interactive
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollToRow(at: IndexPath(row: tableView(tableView, numberOfRowsInSection: 0) - 1, section: 0), at: .bottom, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardChange(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.tableView.contentOffset.y += intersection.height
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func sendMessage(text: String) {
        messages.append(Message(isSelf: true, text: text))
//        tableView.reloadData()
        let ip = IndexPath(row: tableView(tableView, numberOfRowsInSection: 0) - 1, section: 0)
//        tableView.beginUpdates()
        tableView.insertRows(at: [ip], with: .automatic)
//        tableView.endUpdates()
        tableView.scrollToRow(at: ip, at: .bottom, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(with: msg.cellType, for: indexPath)
        switch cell {
        case let cell as ChatViewCell:
            cell.message.text = msg.text
        case let cell as ChatViewOwnCell:
            cell.message.text = msg.text
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(ChatViewController(), animated: true)
    }
    
}

extension ChatViewController.Message {
    var cellType: UITableViewCell.Type {
        return isSelf ? ChatViewOwnCell.self : ChatViewCell.self
    }
}

extension UIView {
    func attach(to item2: Any?) -> (NSLayoutConstraint.Relation) -> ([NSLayoutConstraint.Attribute]) -> [NSLayoutConstraint] {
        return { relation in
            { attrs in
                attrs.map {
                    NSLayoutConstraint(item: self, attribute: $0, relatedBy: relation, toItem: item2, attribute: $0, multiplier: 1, constant: 0)
                }
            }
        }
    }

    func constriant(attribute attr1: NSLayoutConstraint.Attribute) -> (NSLayoutConstraint.Relation) -> (Any?) -> (NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return { relation in
            { item2 in
                { attr2 in
                    NSLayoutConstraint(item: self, attribute: attr1, relatedBy: relation, toItem: item2, attribute: attr2, multiplier: 1, constant: 0)
                }
            }
        }
    }
}
