//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

private let defaults = NSUserDefaults.standardUserDefaults()
private let _singleton = HTTPRequest()

let API_URL = "https://oauth.reddit.com"

class HTTPRequest: NSObject {
    
    class func session() -> HTTPRequest { return _singleton }
    
    var redditUserName = ""
    
    var once: dispatch_once_t = 0
    
    var token: String? {
        
        get {
            //return the value of the token when this is called
            return defaults.objectForKey("TOKEN") as? String
            
        }
        
        set {
            
            //sets a new token value
            defaults.setValue(newValue, forKey: "TOKEN")
            //gets saved into NSDefaults
            defaults.synchronize()
            
        }
        
    }
    
    func logoutAndDeleteToken() {
        
        defaults.removeObjectForKey("TOKEN")
    }
    
    func getUserIdentity(completion: () -> Void) {
        
        let info = [
            
            "method" : "GET",
            "endpoint" : "/api/v1/me"
            
            ] as [String:AnyObject]
        
        
        requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
            
            print("This is a Identity info + \(responseInfo)")
            
            if let redditIdentity = responseInfo as? [String:AnyObject] {
                
                if  let redditUserName = redditIdentity["name"] as? String {
                
                    self.redditUserName = redditUserName
               
                } else {
                    
                    HTTPRequest.session().logoutAndDeleteToken()
                    
                }
                
            }
            
        })

        completion()

    }
    
    func upvoteAndDownvote(linkName: String, direction: Int, completion: () -> Void) {
        
        if token == nil {
            
            Alert.session().loginAlert()
            
        } else {
        
            let info = [
                
                "method" : "POST",
                "endpoint" : "/api/vote",
                
                "parameters" : [
                
                    "id" : "t3_\(linkName)",
                    "dir" : "\(direction)" //1 = upvote, 0 = reset vote, -1 = downvote
                    
                ]
        
                ] as [String:AnyObject]
            
            requestWithInfo(info, andCompletion: { (responseInfo) -> Void in
                
                print("This is a Vote info + \(responseInfo)")
                
            })
            
        }
        
        completion()

    }
    
    func requestWithInfo(info: [String:AnyObject], andCompletion completion: ((responseInfo: AnyObject?) -> Void)?) {
        
        let endpoint = info["endpoint"] as! String
        
        //query parameters for GET request
        if let query = info["query"] as? [String:AnyObject] {
            
            var first = true
            
            for (_,_) in query {
                
                //choose sign if it is first ?(then) else :
                _ = first ? "?" : "&"
                
                //set first the first time it runs
                first = false
                
            }
            
        }
        
        if let url = NSURL(string: API_URL + endpoint) {
            
            let request = NSMutableURLRequest(URL: url)
            
            //NSMutableURLRequest is needed with HTTPMethod
            request.HTTPMethod = info["method"] as! String
            
            if let token = token {
                
                request.setValue("bearer " + token, forHTTPHeaderField: "Authorization")
                
            }
            
            //////// BODY (only run this code if HTTPMethod != "GET"
            
            if let bodyInfo = info["parameters"] as? [String:AnyObject] {
                
                var bodyString = ""
                
                for (key,value) in bodyInfo {
                    
                    if bodyString != "" { bodyString += "&" }
                    
                    bodyString += "\(key)=\(value)"
                    
                }
                
                request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
                
            }
            
            //////// BODY
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in

                //dictionary that comes back
                guard let data = data else { return }
                do {
                    if let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject] {
                    
                    //safe optional in case no data comes back
                    //responseInfo completion block is a function being run above
                    completion?(responseInfo: json)
                    
                    }
                } catch let e as NSError {
                    print(e)
                }
            })
            
        }
        
    }
    
}
