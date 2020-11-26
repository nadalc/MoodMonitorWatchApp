//
//  HelpCenterViewController.swift
//  SilverCloud
//
//  Created by Maria Ortega on 20/08/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit
import WebKit

protocol HelpCenterDelegate: class {
     func refreshHomeContent(url: URL) 

}

class HelpCenterViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties
     weak var delegate: HelpCenterDelegate!
     static let identifier = "HelpCenterViewController"
     let websiteDataStore = WKWebsiteDataStore.nonPersistent()
     private var loadingView = UIView()
     private let actInd = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
     private var viewModel: HelpCenterViewModel!
     private var mappingData: AppMapping!
     private var url: String?
     var webView: WKWebView?


    // MARK: - Setups

     override func viewDidLoad() {
          super.viewDidLoad()
          viewModel = HelpCenterViewModel(view: self)
          loadWebView(url: url ?? APIConstants.helpURL)
    }
     
     func setupView(url: String?, mappingData: AppMapping?) {
          self.url = url ?? APIConstants.helpURL
          self.mappingData = mappingData
     }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
     
    // MARK: - Spinner

     func showLoadingView(isLoading: Bool) {
          if self.loadingView.isDescendant(of: view) {
               self.view.bringSubviewToFront(loadingView)
               loadingView.isHidden = !isLoading
               isLoading ? self.actInd.startAnimating() : self.actInd.stopAnimating()
          } else {
               addloadingWebView()
          }
     }
     
     func addloadingWebView(_ isDownloading: Bool? = false) {
         loadingView = UIView(frame: CGRect(x: view.frame.midX - 75, y: view.frame.midY - 25, width: 150, height: 50))
         loadingView.backgroundColor = UIColor( white:1, alpha: 0.8 )
         loadingView.layer.cornerRadius = 2
         
         // Initialise spinner
         actInd.color = UIColor(red: (0/255.0), green: (184/255.0), blue:(214/255.0), alpha: 1)
         actInd.frame = CGRect(x: 2, y: 2, width: 50, height: 50)
         
         // Set label and text
         let txtLabel = UILabel(frame: CGRect(x: 60, y: 5, width: 80, height: 40))
         txtLabel.text = "Loading..."
         actInd.startAnimating()
         
         // Add to view
         loadingView.addSubview(actInd)
         loadingView.addSubview(txtLabel)
         view.addSubview(loadingView)
     }
}

// MARK: - WebView

extension HelpCenterViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIWebViewDelegate {
     
     private func loadWebView(url: String) {
          self.showLoadingView(isLoading: true)
          let config = self.setupConfig()
          config.websiteDataStore = self.websiteDataStore
          if let urlPath = URL(string: url), let cookies = HTTPCookieStorage.shared.cookies(for: urlPath), cookies.count > 0, let sessionCookie = cookies.first(where: { $0.name as String == APIConstants.sessionid }) {
               config.websiteDataStore.httpCookieStore.setCookie(sessionCookie, completionHandler: {
                    self.initWebView(config: config, url: url)
               })
          } else {
               self.initWebView(config: config, url: url)
          }
     }
     
     private func initWebView(config: WKWebViewConfiguration, url: String) {
          self.webView = WKWebView(delegateView: self, config: config)
          guard let webView = self.webView else {
               return
          }
          webView.allowsBackForwardNavigationGestures = true
          self.contentView.addSubview(webView)
          webView.setDelegateViews(self)
          self.webView?.loadRequestFromString(url)
     }
     
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          self.showLoadingView(isLoading: false)
     }
     
     func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
         self.showLoadingView(isLoading: false)
     }
     
     func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         self.showLoadingView(isLoading: false)
     }
     
     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
     }
     
     func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
          
          if let url = navigationAction.request.url {
               // First lets see if it an external URL
               if !url.absoluteString.hasPrefix(APIConstants.domainURL) {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
               }
               if !url.path.starts(with: "/help") {
                    self.delegate.refreshHomeContent(url:url)
                    self.dismiss(animated: true)
                    decisionHandler(.cancel)
                    return;
               }
          }
          decisionHandler(.allow)
     }
}
