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
            NetworkManager.sharedInstance.processOAuthResponse(handleOpenURL: url)
            NSNotificationCenter.defaultCenter().postNotificationName("dismissVC", object: nil)
            return true
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