//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

private let _singleton = Alert()

class Alert: UIAlertController {
    
    class func session() -> Alert { return _singleton }
    
    func loggedOutAlert() {
        
        let alert = UIAlertView()
        alert.title = "mité"
        alert.message = "You have been logged out."
        alert.addButtonWithTitle("Dimiss")
        alert.show()
        
    }
    
    func loginAlert() {
        
        let alert = UIAlertView()
        alert.title = "mité"
        alert.message = "Login to use this feature."
        alert.addButtonWithTitle("Dimiss")
        alert.show()
        
    }
    
    func successfulLoginAlert() {
        
        let alert = UIAlertController(title: "mité", message: "Login successful.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dimiss", style: UIAlertActionStyle.Default, handler: nil))
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0*Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func sendAlert() {
        
        let alert = UIAlertController(title: "mité", message: "Subreddit results returned empty.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dimiss", style: UIAlertActionStyle.Default, handler: nil))
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0*Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
        
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    
        }
        
    }
    
}






