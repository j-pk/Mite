//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//
 
 import UIKit
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        print(paths[0])
        
        if let defaultPreferencePlistPath = NSBundle.mainBundle().pathForResource("Menu", ofType: "plist") {
            if let defaultPreference = NSDictionary(contentsOfFile: defaultPreferencePlistPath) {
                
                menuDefaults.registerDefaults(defaultPreference as! [String : AnyObject])
                menuDefaults.setObject(defaultPreference, forKey: "defaults")
                
                if let buttonOne = defaultPreference["buttonOneDefault"] as? String {
                        MenuDefaults.session().buttonOne = buttonOne
                }
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        print(url.scheme)
        print(url)
        
        if url.scheme == "miteapp" {
            
            let breakResponse = url.query?.componentsSeparatedByString("&")
            let codePredicate = NSPredicate(format:"SELF BEGINSWITH %@", "code=")
            let getTheCode = breakResponse?.filter { codePredicate.evaluateWithObject($0) }
            
            if let code = getTheCode?[0].stringByReplacingOccurrencesOfString("code=", withString: "") {
                
                print(code)
                
                let redditTokenRequestEndpoint = "https://www.reddit.com/api/v1/access_token"
                let request = NSMutableURLRequest(URL: NSURL(string: redditTokenRequestEndpoint)!)
                
                request.HTTPMethod = "POST"
                let redditPostRequestWithToken = NSString(format: "grant_type=authorization_code&code=\(code)&redirect_uri=miteApp://miteApp.com")
                print(redditPostRequestWithToken)
                
                request.HTTPBody = redditPostRequestWithToken.dataUsingEncoding(NSUTF8StringEncoding)
    
                let username = miteKey
                let password = ""
                let loginString = NSString(format: "%@:%@", username, password)
                if let loginData = loginString.dataUsingEncoding(NSUTF8StringEncoding)  {
                    
                    let base64LoginString = loginData.base64EncodedStringWithOptions([])
                    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                    
                }
                
                let session = NSURLSession.sharedSession()
                
                session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    guard let data = data else { return }
                    let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print("responseString = \(responseString)")
                    
                    do {
                        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let accessToken = jsonResult?["access_token"] as? String {
                            
                            HTTPRequest.session().token = accessToken
                            print("This is a token: " + "\(accessToken)")
                            
                            self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                            NSNotificationCenter.defaultCenter().postNotificationName("sendAlert", object: nil)
                        }
                    } catch let e as NSError {
                        print(e)
                    } catch {
                        print(error)
                    }
                
            }).resume()
                
            }
            
        }
        
        return false
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
}