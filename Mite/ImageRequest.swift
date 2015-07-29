//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

private let _singleton = ImageRequest()

class ImageRequest: NSObject {
    
    class func session() -> ImageRequest { return _singleton }
    
    var images: [String] = []
    var redditID: [String] = []
    var redditScore: [Int] = []
    var redditTitle: [String] = []
    var pageRedditAfter = ""
    var searchRedditString = ""
    
    func jsonRequestForImages(url: String, completion: (images: [String]) -> ()) {
        
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
                                
                                if let preview = data["preview"] as? [String:AnyObject] {
                                    
                                    if let id = data["id"] as? String {
                                        
                                        self.redditID.append(id)
                                        
                                        println("THIS IS ID \(id)")
                                        
                                    }
                                    
                                    if let score = data["score"] as? Int {
                                        
                                        self.redditScore.append(score)
                                        
                                        println("THIS IS SCORE \(score)")
                                    }
                                    
                                    if let title = data["title"] as? String {
                                        
                                        self.redditTitle.append(title)
                                        
                                        println("THIS IS TITLE \(title)")
                                        
                                    }
                                    
                                    if let previewImages = preview["images"] as? NSArray {
                                        
                                        for resolution in previewImages {
                                            
                                            if let lowResolution = resolution["resolutions"] as? [[String:AnyObject]] {
                                                
                                                for width in lowResolution {

                                                    if let lowResolutionWidth = width["width"] as? Int {
                                                        
                                                        if lowResolutionWidth == 320 {
                                                            
                                                            if let url = width["url"] as? String {
                                                                
                                                               var modifiedURL = url.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                                                                self.images.append(modifiedURL)
                                                                
                                                            }
                                                         
                                                        }
                                                        
                                                    }
                                                
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
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
