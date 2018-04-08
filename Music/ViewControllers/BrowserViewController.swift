//
//  BrowserViewController.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let url = URL(string: "https://google.com")!
        //webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        searchBar.delegate = self
        
        progressView.alpha = 0.0
        progressView.progress = 0.0
    }
    
    // MARK: - WebView delegate methods
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
//        progressView.setProgress(0.1, animated: true)
//        progressView.alpha = 1.0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish to load")
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.progressView.setProgress(1.0, animated: true)
            self.progressView.alpha = 0.0
        }, completion: { (Bool) -> Void in
            self.progressView.progress = 0.0
        })
    }
    
    // MARK: - SearchBar delegate methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            let stringForGoogle = searchText.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            let url = URL(string: "http://www.google.com/search?q=\(String(describing: stringForGoogle))")
            let request = URLRequest(url: url!)
            self.webView.load(request)
        }
        
        view.endEditing(true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            self.progressView.alpha = 1.0
        }
    }

}
