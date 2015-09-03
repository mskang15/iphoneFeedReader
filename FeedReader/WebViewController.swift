//
//  WebViewController.swift
//  FeedReader
//
//  Created by Moon-Seok Kang on 6/1/15.
//  Copyright (c) 2015 Moon Kang. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var article: ArticleModel = ArticleModel()
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = article.title
        
        let url = NSURL(string: article.link)!
        let request = NSURLRequest(URL: url)
        
        webView.loadRequest(request)
    }
    
    
}
