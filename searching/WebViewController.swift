//
//  WebViewController.swift
//  test
//
//  Created by ssyb on 2024/4/19.
//

import UIKit
import WebKit
class WebViewController: UIViewController,WKNavigationDelegate{

    var productURL: String?
    override func viewDidLoad() {
        if productURL==nil{return}
        super.viewDidLoad()
        productDetail.navigationDelegate=self
        load()
        // Do any additional setup after loading the view.
    }
    func load()
    {
        if let url = URL(string: productURL!){
            let request = URLRequest(url: url)
            productDetail.load(request)
        }
    }
    @IBOutlet weak var productDetail: WKWebView!
    


}
