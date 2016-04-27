//
//  SplashScreenViewController.swift
//  Mite
//
//  Created by Jameson Kirby on 4/23/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.sharedInstance.requestImages("https://www.reddit.com/.json") { _ in
            self.performSegueWithIdentifier("launchSegue", sender: self)
        }
    }
}
