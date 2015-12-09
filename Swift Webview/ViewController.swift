//
//  ViewController.swift
//  Swift Webview
//
//  Created by Eric London on 12/9/15.
//  Copyright © 2015 Eric London. All rights reserved.
//

import UIKit
// add WebKit include:
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    @IBOutlet var containerView: UIView!
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        
        // the following code is used to execute custom javascript
        // in the webview to initialize the webviewer object
        let contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "window.webviewer.init()",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        
        // this code to used to allow the webview to send messages to swift
        // via: webkit.messageHandlers.javascriptHandler.postMessage(message);
        contentController.addScriptMessageHandler(
            self,
            name: "javascriptHandler"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // create the webview with the above configuration options
        self.webView = WKWebView(frame: self.containerView.frame, configuration: config)
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the device uuid, it will be passed to the webview:
        let device_uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        // define the api path, and load the request in the webview:
        let api_host = "https://rails-swift-webview.ngrok.com?uuid=" + device_uuid
        let url = NSURL(string: api_host)
        let req = NSURLRequest(URL: url!)
        self.webView!.loadRequest(req)
        
        // the following is used to implement didFinishNavigation
        self.webView!.navigationDelegate = self
        
    }
    
    func webView(webView: WKWebView,
        didFinishNavigation navigation: WKNavigation!){
            NSLog("webview finished loading")
            
            // when the webview has finished loading, send it a message via javascript
            self.webView!.evaluateJavaScript("window.webviewer.ping()", completionHandler:  nil)
            
    }
    
    func userContentController(userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage) {
            // NSLog(message.name)
            NSLog(message.body as! String)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
