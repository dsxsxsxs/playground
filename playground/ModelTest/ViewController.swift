//
//  ViewController.swift
//  playground
//
//  Created by dsxs on 2017/12/22.
//  Copyright © 2017年 dsxs. All rights reserved.
//

import UIKit
import WebKit

struct TestModel{
    var id = 0
    var created_at:Date = Date()
    var title = ""
    var data = Data()
}
extension TestModel:OrzModel{
    func primaryKey() -> (String, PrimaryKeyDecorator) {
        return ("id", .autoIncrement)
    }
    
    func options() -> [String : String]? {
        return nil
    }

    init?(from dictionary: [String : Any]) {
        print(dictionary)
        guard
            let i = dictionary["id"] as? Int,
            let c = dictionary["created_at"] as? Double,
            let t = dictionary["title"] as? String
            else{
                return nil
        }
        id = i
        created_at = Date(timeIntervalSince1970: c)
        title = t
    }
}

class ViewController: UIViewController {
    
    weak var webView:WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        createWebView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func createWebView() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let config = WKWebViewConfiguration()
        config.processPool = delegate?.webViewProcessPool ?? WKProcessPool()
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.webView = webView
        webView.load(URLRequest(url: URL(string: "https://www2.cr.mufg.jp/newsplus/?cardBrand=0013&lid=news_nicos")!))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doPicker(_ sender: Any) {
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
extension ViewController: WKUIDelegate, WKNavigationDelegate{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let newWV = WKWebView(frame: view.bounds, configuration: configuration)
        newWV.uiDelegate = self
        newWV.navigationDelegate = self
        view.addSubview(newWV)
        DispatchQueue.main.async {
            webView.removeFromSuperview()
            self.webView = newWV
        }
        newWV.load(navigationAction.request)
        print("newwvwith req", navigationAction.request.url?.absoluteString ?? "")
        return newWV
    }
}
