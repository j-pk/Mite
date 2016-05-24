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

enum Router: URLRequestConvertible {
    static let baseURLString = "https://oauth.reddit.com"
    static var OAuthtoken = NetworkManager.sharedInstance.token
    
    case GetIdentity
    case GetUserPreferences
    case UpvoteAndDownvote(linkName: String, direction: Int)
    
    var method: Alamofire.Method {
        switch self {
        case .GetIdentity: return .GET
        case .GetUserPreferences: return .GET
        case .UpvoteAndDownvote: return .POST
        }
    }
    
    var path: String {
        switch self {
        case .GetIdentity: return "/api/v1/me"
        case .GetUserPreferences: return "/api/v1/me/prefs"
        case .UpvoteAndDownvote: return "/api/vote"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        URLRequest.HTTPMethod = method.rawValue
        
        if let token = Router.OAuthtoken {
            URLRequest.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .UpvoteAndDownvote(let linkName, let direction):
            let parameters = [
                "id" : "t3_\(linkName)",
                "dir" : "\(direction)"
            ]
            return Alamofire.ParameterEncoding.URL.encode(URLRequest, parameters: parameters).0
        default:
            return URLRequest
        }
    }
}

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    var pageRedditAfter = ""
    var searchRedditString = ""
    var loggedIn: Bool = false
    var redditUser: User?
    var redditUserPreferences: Preferences?
    
    private let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let API_URL = "https://oauth.reddit.com"
    
    var token: String? {
        get {
            return defaults.objectForKey("AccessToken") as? String
        }
        set {
            defaults.setValue(newValue, forKey: "AccessToken")
            defaults.synchronize()
        }
    }
    
    var refreshToken: String? {
        get {
            return defaults.objectForKey("RefreshToken") as? String
        }
        set {
            defaults.setValue(newValue, forKey: "RefreshToken")
            defaults.synchronize()
        }
    }
    
    func logoutAndDeleteToken() {
        defaults.removeObjectForKey("AccessToken")
    }
    
    func confirmUserLoginStatus() {
        if self.token != nil {
            Alamofire.request(Router.GetIdentity)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        break
                    case .Failure:
                        NetworkManager.sharedInstance.refreshAccessToken()
                        NotificationManager.sharedInstance.showNotificationWithTitle("Attempting to login with Reddit", notificationType: .Error, timer: 2.0)
                        delay(2.0) {
                            NetworkManager.sharedInstance.getUser()
                        }
                    }
                    
                    if let JSONData = response.result.value {
                        let json = JSON(JSONData)
                        print(json)
                        do {
                            let parsedData = try UserContract.parseJSON(json)
                            self.redditUser = parsedData
                            self.loggedIn = true
                        } catch let error {
                            print(error)
                        }
                    }
            }
        } else {
            print("empty token")
        }
    }
    
    func getUser() {
        Alamofire.request(Router.GetIdentity)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success:
                    break
                case .Failure:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Login to Reddit", notificationType: .Error, timer: 2.0)
                }
                if let JSONData = response.result.value {
                    let json = JSON(JSONData)
                    print(json)
                    do {
                        let parsedData = try UserContract.parseJSON(json)
                        self.redditUser = parsedData
                        self.loggedIn = true
                    } catch let error {
                        print(error)
                    }
                }
        }
    }
    
    func getUserPreferences(completion:(() -> ())) {
        if self.token != nil {
            Alamofire.request(Router.GetUserPreferences)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    break
                case .Failure:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Failed to get preferences", notificationType: .Error, timer: 2.0)
                }
                if let JSONData = response.result.value {
                    let json = JSON(JSONData)
                    print(json)
                    do {
                        let parsedData = try PreferencesContract.parseJSON(json)
                        self.redditUserPreferences = parsedData
                        completion()
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func requestImages(url: String, completion: (data: [MiteImage]) -> ()) {
        Alamofire.request(.GET, url)
            .validate()
            .responseJSON { response in
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
                    NSNotificationCenter.defaultCenter().postNotificationName("notifyFailedSearch", object: nil)
                }
            }
        }
    }
    
    
    func fetchImage(fromUrl url:String, completion: (UIImage -> Void)) -> (Request) {
        return Alamofire.request(.GET, url).responseImage { (response) -> Void in
            guard let image = response.result.value else { return }
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
    
    func processOAuthResponse(handleOpenURL url: NSURL) {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        if let queryItems = components?.queryItems {
            let code = queryItems.filter({ $0.name.lowercaseString == "code" }).first
            guard let parsedCode = code?.value else { NotificationManager.sharedInstance.showNotificationWithTitle("Failed to Authenticate with Reddit", notificationType: .Error, timer: 3.0); return }
            let tokenPath = "https://www.reddit.com/api/v1/access_token"
            let tokenParameters = [
                "grant_type": "authorization_code",
                "code": parsedCode,
                "redirect_uri": "miteApp://miteApp.com"
            ]
            print("param: ", tokenParameters)
            Alamofire.request(.POST, tokenPath, parameters: tokenParameters)
                .authenticate(user: "\(miteKey)", password: "")
                .validate()
                .response { (request, response, results, error) in
                if error != nil {
                    NotificationManager.sharedInstance.showNotificationWithTitle("Failed to Authenticate with Reddit", notificationType: .Error, timer: 3.0)
                }
                print("request: ", request)
                print("headers: ", response?.allHeaderFields)
                print("results: ", results)
                if let JSONData = results {
                    let json = JSON(data: JSONData)
                    print(json)
                    if let accessToken = json["access_token"].string, refreshToken = json["refresh_token"].string {
                        print(accessToken, refreshToken)
                        self.token = accessToken
                        self.refreshToken = refreshToken
                    }
                }
            }
        }
    }
    
    func refreshAccessToken() {
        guard let refreshToken = self.refreshToken else { return }
        let refreshPath = "https://www.reddit.com/api/v1/access_token"
        let refreshParameters =  [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        Alamofire.request(.POST, refreshPath, parameters: refreshParameters)
            .authenticate(user: "\(miteKey)", password: "")
            .validate()
            .response { (request, response, results, error) in
                if error != nil {
                    NotificationManager.sharedInstance.showNotificationWithTitle("Failed to Authenticate with Reddit, try again.", notificationType: .Error, timer: 3.0)
                }
                print("request: ", request)
                print("headers: ", response?.allHeaderFields)
                print("results: ", results)
                if let JSONData = results {
                    let json = JSON(data: JSONData)
                    print(json)
                    if let accessToken = json["access_token"].string {
                        print(accessToken, refreshToken)
                        self.token = accessToken
                    }
                }
                
        }
        
    }
}

