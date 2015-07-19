//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

private let _singleton = ImageRequest()

class ImageRequest: NSObject {
    
    class func session() -> ImageRequest { return _singleton }
    
    var images: [String:[String:AnyObject]] = [:]
    var pageRedditAfter = ""
    var searchRedditString = ""
    
    func jsonRequestForImages(url: String, completion: (images: [String:[String:AnyObject]]) -> ()) {
        
        ///REDDIT JSON
        
        if let url = NSURL(string: url) {
            
            let request = NSURLRequest(URL: url)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    
                    if let pageAfter = jsonResult["data"] as? NSDictionary {
                        
                        if let after = pageAfter["after"] as? String {
                        
                        self.pageRedditAfter = after
                            
                        }
                        
                    }
                    
                    if let results = jsonResult["data"]!["children"] as? NSArray {
                        
                        if results.count == 0 {
                            
                            Alert.session().sendAlert()
                        }
                        
                        for result in results {
                            
                            if let data = result["data"] as? [String:AnyObject] {
                                
                                if let imageURL = data["url"] as? String, id = data["id"] as? String {
                                    
                                    self.images[id] = data
                                    
                                }
                                
                            }
                            
                        }

                    }
                    
                    completion(images: self.images)
                    
                }
                
                if error != nil {
                    println("error= \(error)")
                    return
                }
                
            }
            
        }

    }
    
}
