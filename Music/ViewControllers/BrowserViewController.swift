//
//  BrowserViewController.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "http://google.com")!
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, -49, 0)
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -49, 0)
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        (searchBar.value(forKey: "searchField") as! UITextField).textAlignment = .center
        (searchBar.value(forKey: "_searchField") as! UITextField).clearButtonMode = .whileEditing
        
        progressView.alpha = 0.0
        progressView.progress = 0.0
    }
    
    // MARK: - WebView delegate methods
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url?.host {
            searchBar.text = url
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.progressView.setProgress(1.0, animated: true)
            self.progressView.alpha = 0.0
        }, completion: { (Bool) -> Void in
            self.progressView.progress = 0.0
        })
    }
    
    // MARK: - SearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        (searchBar.value(forKey: "searchField") as! UITextField).textAlignment = .left
        if let url = webView.url?.absoluteString {
            searchBar.text = url
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        (searchBar.value(forKey: "searchField") as! UITextField).textAlignment = .center
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        if let url = webView.url?.host {
            searchBar.text = url
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            let arrayOfComponents = searchText.components(separatedBy: ".")
            if arrayOfComponents.count >= 2 {
                if arrayOfComponents.first == "www" {
                    let url = URL(string: "http://\(String(describing: searchText))")
                    let request = URLRequest(url: url!)
                    self.webView.load(request)
                } else {
                    let url = URL(string: "http://www.\(String(describing: searchText))")
                    let request = URLRequest(url: url!)
                    self.webView.load(request)
                }
            } else {
                let stringForGoogle = searchText.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let url = URL(string: "http://www.google.com/search?q=\(String(describing: stringForGoogle))")
                let request = URLRequest(url: url!)
                self.webView.load(request)
            }
            
        }
        
        view.endEditing(true)
    }
    
    // MARK: - ProgressView delegate methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            self.progressView.alpha = 1.0
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            changeTabBar(hidden: true, animated: true)
            webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, -49, 0)
            webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -49, 0)
        } else {
            changeTabBar(hidden: false, animated: true)
            webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
    }
    
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        if tabBar!.isHidden == hidden {
            return
        }
        
        let frame = tabBar?.frame
        let offset = (hidden ? (frame?.size.height)! : -(frame?.size.height)!)
        let duration: TimeInterval = (animated ? 0.5 : 0.0)
        tabBar?.isHidden = false
        if frame != nil {
            UIView.animate(withDuration: duration, animations: {
                tabBar!.frame = frame!.offsetBy(dx: 0, dy: offset)
            }, completion: {
                if $0 {
                    tabBar?.isHidden = hidden
                }
            })
        }
    }

}
