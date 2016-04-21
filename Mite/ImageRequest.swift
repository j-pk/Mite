//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

private let _singleton = ImageRequest()

class ImageRequest: NSObject {
    
    class func session() -> ImageRequest { return _singleton }
    
    typealias redditDataTuple = (id:String, score:Int, title:String, url:String, image:UIImage)
    
    var tempRedditData: (id:String, score:Int, title:String, url:String, image:UIImage) = (id:"", score:0 , title:"", url:"", image: UIImage.imageWithColor(UIColor.clearColor()))
    var redditData: [redditDataTuple] = []
    var pageRedditAfter = ""
    var searchRedditString = ""
    
    func jsonRequestForImages(url: String, completion: (images: [redditDataTuple]) -> ()) {
        
        ///REDDIT JSON
        
        if let url = NSURL(string: url) {
            
            let request = NSURLRequest(URL: url)
            
            let session = NSURLSession.sharedSession()
            
            session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                guard let data = data else { return }
                
                do {
                    
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        
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
                                            
                                            self.tempRedditData.id = id
                                            
                                        }
                                        
                                        if let score = data["score"] as? Int {
                                            
                                            self.tempRedditData.score = score
                                            
                                        }
                                        
                                        if let title = data["title"] as? String {
                                            
                                            self.tempRedditData.title = title
                                            
                                        }
                                        
                                        if let url = data["url"] as? String {
                                            
                                            self.tempRedditData.url = url
                                            
                                        }
                                        
                                        if let previewImages = preview["images"] as? NSArray {
                                            
                                            for resolution in previewImages {
                                                
                                                if let lowResolution = resolution["resolutions"] as? [[String:AnyObject]] {
                                                    
                                                    for width in lowResolution {
                                                        
                                                        if let lowResolutionWidth = width["width"] as? Int {
                                                            
                                                            if lowResolutionWidth == 320 {
                                                                
                                                                if let url = width["url"] as? String {
                                                                    
                                                                    let modifiedURL = url.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                                                    
                                                                    if let url = NSURL(string: modifiedURL) {
                                                                        
                                                                        if let imageData = NSData(contentsOfURL: url) {
                                                                            
                                                                            if let image = UIImage(data: imageData) {
                                                                                
                                                                                self.tempRedditData.image = image
                                                                            }
                                                                            
                                                                        }
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                }
                                                                
                                                                self.redditData.append(self.tempRedditData)
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
                        
                        completion(images: self.redditData)
                        
                    }
                    
                    if error != nil {
                        print("error= \(error)")
                        return
                    }
                    
                } catch let e as NSError {
                    print(e)
                } catch {
                    print(error)
                }
                
            }).resume()
            
        }
    }
}
