//
//  NetworkManager.swift
//  Mite
//
//  Created by Jameson Kirby on 4/23/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let API_URL = "https://oauth.reddit.com"
    private var redditUserName = ""
    
    typealias redditDataTuple = (id:String, score:Int, title:String, url:String, image:UIImage)
    
    private var tempRedditData: (id:String, score:Int, title:String, url:String, image:UIImage) = (id:"", score:0 , title:"", url:"", image: UIImage.imageWithColor(UIColor.clearColor()))
    var redditData: [redditDataTuple] = []
    var pageRedditAfter = ""
    var searchRedditString = ""
    
    var token: String? {
        get {
            return defaults.objectForKey("TOKEN") as? String
        }
        set {
            defaults.setValue(newValue, forKey: "TOKEN")
        }
    }
    
    func logoutAndDeleteToken() {
        defaults.removeObjectForKey("TOKEN")
    }
    
    func getUserIdentity() -> String {
        let headers = [
            "Authorization": "bearer \(token)",
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(.GET, API_URL + "/api/v1/me", headers: headers)
            .responseJSON { response in
                
                //error example
                switch response.result {
                case .Success:
                    print("Validation Successful")
                case .Failure(let error):
                    print(error)
                }
                
                if let JSONData = response.result.value {
                    let parsedJSON = JSON(JSONData)
                    if  let redditUserName = parsedJSON["name"].string {
                        return self.redditUserName = redditUserName
                    } else {
                        HTTPRequest.session().logoutAndDeleteToken()
                    }
                }
        }
        return self.redditUserName
    }
    
    func upvoteAndDownvote(linkName: String, direction: Int, completion: () -> Void) {
        if token == nil {
            Alert.session().loginAlert()
            return
        }
        
        let headers = [
            "Authorization": "bearer \(token)",
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        let parameters = [
            "id" : "t3_\(linkName)",
            "dir" : "\(direction)" //1 = upvote, 0 = reset vote, -1 = downvote
        ]
        
        Alamofire.request(.POST, API_URL + "/api/vote", headers: headers, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("Validation Successful")
                case .Failure(let error):
                    print(error)
                }
        }
        completion()
    }
    
    func requestImages(url: String, completion: (images: [redditDataTuple]) -> ()) {
        Alamofire.request(.GET, url)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("Validation Successful")
                case .Failure(let error):
                    print(error)
                }
            if let JSONData = response.result.value {
                let parsedJSON = JSON(JSONData)
                if  let pageRedditAfter = parsedJSON["data"]["after"].string {
                    self.pageRedditAfter = pageRedditAfter
                    print(pageRedditAfter)
                }
                if let results = parsedJSON["data"]["children"].array {
                    if results.count == 0 {
                        Alert.session().sendAlert()
                    }
                    for result in results {
                        guard let dataDict = result["data"].dictionary else { continue }
                        if let images = dataDict["preview"]?["images"].array {
                            for image in images {
                                if let resolutions = image["resolutions"].array {
                                    for resolution in resolutions {
                                        if let width = resolution["width"].int where width == 320 {
                                            if let previewId = dataDict["id"]?.string,
                                                score = dataDict["score"]?.int,
                                                title = dataDict["title"]?.string,
                                                url = dataDict["url"]?.string {
                                                
                                                self.tempRedditData.id = previewId
                                                self.tempRedditData.score = score
                                                self.tempRedditData.title = title
                                                self.tempRedditData.url = url
                                            }
                                            let url = resolution["url"].string
                                            guard let modifiedURL = url?.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil) else { return }
                                            
                                            if let url = NSURL(string: modifiedURL) {
                                                if let imageData = NSData(contentsOfURL: url) {
                                                    if let image = UIImage(data: imageData) {
                                                        self.tempRedditData.image = image
                                                    }
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
                self.redditData = self.redditData.filter { $0.id == $0.id }
                
                completion(images: self.redditData)
        }
    }
}

