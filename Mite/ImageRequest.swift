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
                                
                                println(data)
                                
                                if let preview = data["preview"] as? [String:AnyObject] {
                                    
                                    println("this is preview \(preview)")
                                    
                                    if let previewImages = preview["images"] as? NSArray {
                                    
                                        println("this is images \(previewImages)")
                                        
                                        for resolution in previewImages {
                                            
                                            if let lowResolution = resolution["resolutions"] as? [[String:AnyObject]] {
                                                
                                                println("This is low resolution \(lowResolution)")
                                                
                                                for width in lowResolution {
                                                    
                                                    println("What the hell is this stuff \(width)")
                                                    
                                                    if let lowResolutionWidth = width["width"] as? Int {
                                                        
                                                        if lowResolutionWidth == 320 {
                                                            
                                                            if let url = width["url"] as? String {
                                                                
                                                                println("This is the width url \(url)")
                                                                
                                                            }
                                                         
                                                        }
                                                        
                                                    }
                                                
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
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
