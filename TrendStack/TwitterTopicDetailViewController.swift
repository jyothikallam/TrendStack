//
//  TopicDetailViewController.swift
//  TrendStack
//
//  Created by Chanikya on 28/02/2016.
//  Copyright © 2016 joe. All rights reserved.
//

import UIKit

class TwitterTopicDetailViewController: UIViewController {
    
    var url:String   = "https://twitter.com"
    var name:String  = String()
    var query:String = String()

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webUrl = NSURL(string: url)
        webView.loadRequest(NSURLRequest(URL: webUrl!))
    }
}
