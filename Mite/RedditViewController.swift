//
//  RedditViewController.swift
//  Mite
//
//  Created by jpk on 8/5/15.
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class RedditViewController: UIViewController {
    
    @IBOutlet weak var redditWebView: UIWebView!
    
    @IBOutlet weak var cancelWebViewButton: UIBarButtonItem!

    var url: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = self.url {
            
            self.url = url
            
        }
        
        let request = NSURLRequest(URL: url!)
        redditWebView.loadRequest(request)
                
    }
    
    @IBAction func cancelWebView(sender: AnyObject) {
    
        dismissViewControllerAnimated(true, completion: nil)
        
    }

    
}
