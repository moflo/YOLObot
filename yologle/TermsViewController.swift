//
//  TermsViewController.swift
//  oyawatch
//
//  Created by d. nye on 11/20/18.
//  Copyright © 2018 Mobile Flow LLC. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController, WKNavigationDelegate {

    var termsOrPrivacy = true

    @IBAction func doTermsButton(_ sender: Any) {
        self.termsOrPrivacy = !self.termsOrPrivacy
        DispatchQueue.main.async {
            self.loadTerms()
        }
    }
    
    @IBOutlet weak var webView: WKWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self
        
        webView.allowsBackForwardNavigationGestures = true

        self.loadTerms()
    }
    
    func loadTerms() {
        if self.termsOrPrivacy {
            let url = URL(string: "https://moflo.me/terms.html")!
            webView.load(URLRequest(url: url))
        }
        else {
            let url = URL(string: "https://moflo.me/privacy.html")!
            webView.load(URLRequest(url: url))

        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if url.contains("terms.html") || url.contains("privacy.html") {
                decisionHandler(.allow)
                return
            }
        }
        
        decisionHandler(.cancel)
    }

}
