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
let defaults = NSUserDefaults.standardUserDefaults()

enum Router: URLRequestConvertible {
    static let baseURLString = "https://oauth.reddit.com"
    static var OAuthtoken: String? {
        get {
            return defaults.objectForKey("AccessToken") as? String
        }
    }
    
    case GetIdentity
    case GetUserPreferences
    case UpvoteAndDownvote(linkName: String, direction: Int)
    case PatchLabelNSFWPreferences(labelNSFW: Bool)
    case PatchOver18Preferences(over_18: Bool)
    case MarkImageNSFW(id: String)
    
    var method: Alamofire.Method {
        switch self {
        case .GetUserPreferences, .GetIdentity: return .GET
        case .UpvoteAndDownvote, .MarkImageNSFW: return .POST
        case .PatchLabelNSFWPreferences, .PatchOver18Preferences: return .PATCH
        }
    }
    
    var path: String {
        switch self {
        case .GetIdentity: return "/api/v1/me"
        case .GetUserPreferences, .PatchLabelNSFWPreferences, .PatchOver18Preferences: return "/api/v1/me/prefs"
        case .UpvoteAndDownvote: return "/api/vote"
        case .MarkImageNSFW: return "/api/marknsfw"
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
        case .PatchLabelNSFWPreferences(let labelNSFW):
            let parameters = [
                "label_nsfw" : labelNSFW
            ]
            return Alamofire.ParameterEncoding.JSON.encode(URLRequest, parameters: parameters).0
        case .PatchOver18Preferences(let over_18):
            let parameters = [
                "over_18" : over_18
            ]
            return Alamofire.ParameterEncoding.JSON.encode(URLRequest, parameters: parameters).0
        case .MarkImageNSFW(let id):
            let parameters = [
                "id" : "t3_\(id)"
            ]
            return Alamofire.ParameterEncoding.URL.encode(URLRequest, parameters: parameters).0
        default:
            return URLRequest
        }
    }
}

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    var searchRedditString = ""
    
    private let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
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
                }
            }
        } else {
            print("empty token")
        }
    }
    
    func getUser(completion: ((user: User)->())) {
        Alamofire.request(Router.GetIdentity)
            .validate()
            .responseJSON{ response in
            switch response.result {
            case .Success:
                break
            case .Failure:
                NotificationManager.sharedInstance.showNotificationWithTitle("Login to Reddit", notificationType: .Error, timer: 2.0)
            }
            print(response.debugDescription)
            print(response.response?.allHeaderFields)
            if let JSONData = response.result.value {
                let json = JSON(JSONData)
                print(json)
                do {
                    let parsedData = try UserContract.parseJSON(json)
                    completion(user: parsedData)
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    func getUserPreferences(completion: ((pref: Preferences)->())) {
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
                        completion(pref: parsedData)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func patchOver18Preference(over_18: Bool) {
        Alamofire.request(Router.PatchOver18Preferences(over_18: over_18))
            .validate()
            .responseJSON{ response in

            switch response.result {
            case .Success:
                NotificationManager.sharedInstance.showNotificationWithTitle("Preferences Saved", notificationType: .Error, timer: 2.0)
                
            case .Failure:
                NotificationManager.sharedInstance.showNotificationWithTitle("Preferences Failed to Save", notificationType: .Error, timer: 2.0)
            }
        }
    }
    
    func patchLabelNSFWPreference(labelNSFW: Bool) {
        print("WTF ", labelNSFW)
        Alamofire.request(Router.PatchLabelNSFWPreferences(labelNSFW: labelNSFW))
            .validate()
            .responseJSON{ response in
                print(response.response?.allHeaderFields)
                print(response)
            switch response.result {
            case .Success:
                NotificationManager.sharedInstance.showNotificationWithTitle("Preferences Saved", notificationType: .Error, timer: 2.0)
                
            case .Failure:
                NotificationManager.sharedInstance.showNotificationWithTitle("Preferences Failed to Save", notificationType: .Error, timer: 2.0)
            }
        }
    }
    
    func markImageNSFW(id: String) {
        if token == nil {
            NotificationManager.sharedInstance.showNotificationWithTitle("Login to flag image as NSFW", notificationType: .Error, timer: 2.0)
            return
        }
        Alamofire.request(Router.MarkImageNSFW(id: id))
            .validate()
            .responseJSON{ response in
                print(response.response?.allHeaderFields)
                print(response)
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Flagged Image as NSFW", notificationType: .Error, timer: 2.0)
                    
                case .Failure:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Mod status is required to flag content", notificationType: .Error, timer: 3.0)
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

