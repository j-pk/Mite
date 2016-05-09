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

let redditAPI = "https://www.reddit.com/"

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    var pageRedditAfter = ""
    var searchRedditString = ""
    
    private let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let API_URL = "https://oauth.reddit.com"
    private var redditUserName = ""
    
    var token: String? {
        get {
            return defaults.objectForKey("TOKEN") as? String
        }
        set {
            defaults.setValue(newValue, forKey: "TOKEN")
            defaults.synchronize()
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
                        //HTTPRequest.session().logoutAndDeleteToken()
                    }
                }
        }
        return self.redditUserName
    }
    
    func getUserPreferences() {
        let headers = [
            "Authorization": "bearer \(token)",
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(.GET, API_URL + "/api/v1/me/prefs", headers: headers)
            .responseJSON { response in
                //error example
                print(response.result.debugDescription)
                switch response.result {
                case .Success:
                    print("Validation Successful")
                case .Failure(let error):
                    print(error)
                }

                if let JSONData = response.result.value {
                    let parsedJSON = JSON(JSONData)
                    print(parsedJSON)
                }
        }
    }
    
    func upvoteAndDownvote(linkName: String, direction: Int, completion: () -> Void) {
        if token == nil {
            NotificationManager.sharedInstance.showNotificationWithTitle("Login to use this feature.", notificationType: NotificationType.Error, timer: 2.0)
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
                    NotificationManager.sharedInstance.showNotificationWithTitle("Voted Successfully", notificationType: NotificationType.Success, timer: 1.0)
                case .Failure(let error):
                    NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                    print(error)
                }
        }
        completion()
    }
    
    func requestImages(url: String, completion: (data: [MiteImage]) -> ()) {
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
                    let parsedData = try ImageContract.parseJSON(json)
                    completion(data: parsedData)
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    
    func fetchImage(fromUrl url:String, completion: (UIImage -> Void)) -> (Request) {
        return Alamofire.request(.GET, url).responseImage { (response) -> Void in
            guard let image = response.result.value else { return }
            print(image)
            completion(image)
            ImageCacheManager.sharedInstance.addImageToCache(image, withKey: url)
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
    
    func downloadImage(fromUrl url:String, completion: (String?) -> ()) {
        Alamofire.download(.GET, url, destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes read on main queue: \(totalBytesRead)")
                }
            }
            .response { _, response, _, error in
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
                print(response?.suggestedFilename)
                completion(response?.suggestedFilename)
        }
    }
}

