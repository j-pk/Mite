//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

private let _singleton = MenuDefaults()

private let buttonOneKey = "ONE"
private let buttonTwoKey = "TWO"
private let buttonThreeKey = "THREE"
private let buttonFourKey = "FOUR"
private let buttonFiveKey = "FIVE"

let menuDefaults = NSUserDefaults.standardUserDefaults()


class MenuDefaults: NSObject {
    
    class func session() -> MenuDefaults { return _singleton }
    
    var buttonOne: String? {

        get {
            
            //return the value of the token when this is called
            return menuDefaults.objectForKey(buttonOneKey) as? String
            
        }
        
        set {
            
            //sets a new token value
            menuDefaults.setValue(newValue, forKey: buttonOneKey)
            //gets saved into NSDefaults
            menuDefaults.synchronize()
            
        }
        
    }
    
    var buttonTwo: String? {
        
        get {
            
            return menuDefaults.objectForKey(buttonTwoKey) as? String
        
        }
        
        set {
            
            menuDefaults.setValue(newValue, forKey: buttonTwoKey)
            menuDefaults.synchronize()
            
        }
        
    }
    
    var buttonThree: String? {
        
        get {

            return menuDefaults.objectForKey(buttonThreeKey) as? String
            
        }
        
        set {
            
            menuDefaults.setValue(newValue, forKey: buttonThreeKey)
            menuDefaults.synchronize()
            
        }
        
    }
    
    var buttonFour: String? {
        
        get {

            return menuDefaults.objectForKey(buttonFourKey) as? String
            
        }
        
        set {
            
            menuDefaults.setValue(newValue, forKey: buttonFourKey)
            menuDefaults.synchronize()
            
        }
        
    }
    
    var buttonFive: String? {
        
        get {

            return menuDefaults.objectForKey(buttonFiveKey) as? String
            
        }
        
        set {
            
            menuDefaults.setValue(newValue, forKey: buttonFiveKey)
            menuDefaults.synchronize()
            
        }
        
    }

}