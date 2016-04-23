//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var connectToRedditButton: CustomButton!
    @IBOutlet weak var browseAnonButton: CustomButton!
    
    var randomString: NSString = ""
    var urlToSend: NSURL?
    
    ////////////////////MARK: Load
    
    override func viewWillAppear(animated: Bool) {
        
        connectToRedditButton.hidden = true
        browseAnonButton.hidden = true
        returnButton.alpha = 0
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomString = generateRandomString(20)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        connectToRedditButton.hidden = false
        browseAnonButton.hidden = false
        
        let offSet = view.frame.height * -1
        let bottomOffset = view.frame.height
        self.connectToRedditButton.transform = CGAffineTransformMakeTranslation(0, offSet)
        self.browseAnonButton.transform = CGAffineTransformMakeTranslation(0, bottomOffset)
        
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [], animations: { () -> Void in
            
            self.connectToRedditButton.transform = CGAffineTransformIdentity
            self.browseAnonButton.transform = CGAffineTransformIdentity
            
            }) { (finished) -> Void in
                
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    
                    self.returnButton.alpha = 1
                    
                })
                
        }
        
    }
    
    ////////////////////MARK: Animate & Button Action
    
    @IBAction func browseAnon(sender: UIButton) {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.returnButton.alpha = 0
            
        })
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            
            let offSet = self.view.frame.height * -1
            let bottomOffset = self.view.frame.height
            
            self.connectToRedditButton.transform = CGAffineTransformMakeTranslation(0, offSet)
            self.browseAnonButton.transform = CGAffineTransformMakeTranslation(0, bottomOffset)
            self.connectToRedditButton.alpha = 0
            self.browseAnonButton.alpha = 0
            
            }) { (finished) -> Void in
                
                self.dismissViewControllerAnimated(false, completion: nil)
                
        }
        
    }
    
    @IBAction func connectButtonPressed(sender: UIButton) {
        
        if let authorizationURL = NSURL(string: "https://www.reddit.com/api/v1/authorize?client_id=\(miteKey)&response_type=code&state=\(randomString)&redirect_uri=miteApp://miteApp.com&duration=permanent&scope=identity,vote,read") {
            
            urlToSend = authorizationURL
            
        }
        
    }
    
    func generateRandomString(length: Int) -> NSString {
        
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString = NSMutableString(capacity: length)
        
        for _ in 0..<20 {
            let len = UInt32 (characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.characterAtIndex(Int(rand)))

        }
        print(randomString)
        return randomString
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "redditWebView" {
            
            if let redditVC = segue.destinationViewController as? RedditViewController {
                
                redditVC.url = urlToSend
                
                print(urlToSend)
                
            }
            
        }
    
    }
     
}





