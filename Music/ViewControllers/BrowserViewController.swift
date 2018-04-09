//
//  BrowserViewController.swift
//  Music
//
//  Created by Иван on 07.04.2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        webView.isUserInteractionEnabled = true
        
        webView.addGestureRecognizer(longPressRecognizer)
    }
    
    // MARK: - GestureRecognizer delegate methods
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        print("God, it works")
    }
    
    // MARK: - WebView delegate methods
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url?.host {
            searchBar.text = url
        }
        
        print((webView.url?.pathExtension)!)
        
        if (webView.url?.pathExtension)?.lowercased() == "mp3" {
            let alert = UIAlertController(title: "Song detected", message: "Would You like to download this song?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                let audioUrl = self.webView.url!
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                print(documentsDirectoryURL)
                
                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                print(destinationUrl)
                
                // to check if it exists before downloading it
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("The file already exists at path")
                    
                    // if the file doesn't exist
                } else {
                    // you can use NSURLSession.sharedSession to download the data asynchronously
                    URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                        guard let location = location, error == nil else { return }
                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: location, to: destinationUrl)
                            print("File moved to documents folder")
                            DispatchQueue.main.async {
                                let alert1 = UIAlertController(title: "Success", message: "Song was successfully downloaded.", preferredStyle: .alert)
                                alert1.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.present(alert1, animated: true, completion: nil)
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                            DispatchQueue.main.async {
                                let alert1 = UIAlertController(title: "Fail", message: "error.localizedDescription", preferredStyle: .alert)
                                alert1.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.presentAlert(alert: alert1)
                            }
                        }
                    }).resume()
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.progressView.setProgress(1.0, animated: true)
            self.progressView.alpha = 0.0
        }, completion: { (Bool) -> Void in
            self.progressView.progress = 0.0
        })
        
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'", completionHandler: {(id_t, Error) -> Void in
            print("Ok")
        })
    }
    
    // MARK: - SearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        (searchBar.value(forKey: "searchField") as! UITextField).textAlignment = .left
        if let url = webView.url?.absoluteString {
            searchBar.text = url
            
            let textField = (searchBar.value(forKey: "_searchField") as! UITextField)
            let newPosition = textField.beginningOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            
            let font = (searchBar.value(forKey: "searchField") as! UITextField).font
            (searchBar.value(forKey: "searchField") as! UITextField).font = UIFont.systemFont(ofSize: (font?.pointSize)!)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        (searchBar.value(forKey: "searchField") as! UITextField).textAlignment = .center
        
        let font = (searchBar.value(forKey: "searchField") as! UITextField).font
        (searchBar.value(forKey: "searchField") as! UITextField).font = UIFont.boldSystemFont(ofSize: (font?.pointSize)!)
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
    
    // MARK: - ScrollView delegate methods
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
