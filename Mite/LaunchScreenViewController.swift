//
//  SplashScreenViewController.swift
//  Mite
//
//  Created by Jameson Kirby on 4/23/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    var data = [Dictionary<String, AnyObject>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.performSegueWithIdentifier("launchSegue", sender: self)

    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "launchSegue") {
//                if let mainVC = segue.destinationViewController as? MainCollectionViewController {
//                    mainVC.imageResults = self.data
//                    print(mainVC.imageResults)
//            }
//        }
//    }
}
