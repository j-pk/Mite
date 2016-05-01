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

typealias MiteImages = Dictionary<String, AnyObject>

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    var pageRedditAfter = ""
    var searchRedditString = ""
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let API_URL = "https://oauth.reddit.com"
    private var redditUserName = ""
    
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
    
    func requestImages(url: String, completion: (data: [MiteImages]) -> ()) {
        Alamofire.request(.GET, url).responseJSON { response in
            switch response.result {
            case .Success:
                print("Validation Successful")
            case .Failure(let error):
                print(error)
            }
            if let JSONData = response.result.value {
                let json = JSON(JSONData)
                do {
                    let images = try ImageContract.parseJSON(json)
                    completion(data: images)
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    
    func fetchImage(fromUrl url:String, completion:(UIImage? -> ())) {
        Alamofire.request(.GET, url).validate().response() {
            (request, response, data, error) in
            if let image = ImageCacheManager.sharedInstance.fetchImage(withKey: url) {
                completion(image)
            } else {
                Alamofire.request(.GET, url).validate().response() {
                    (request, response, data, error) in
                    if let imageData = data, let image = UIImage(data:imageData) where error == nil && response != nil {
                        ImageCacheManager.sharedInstance.addImageToCache(image, withKey: url)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func fetchImageData(fromUrl url:String, completion:(NSData? -> ())) {
        Alamofire.request(.GET, url).validate().response() {
            (request, response, data, error) in
            if let imageData = data where error == nil && response != nil {
                completion(imageData)
            } else {
                completion(nil)
            }
        }
    }
}

