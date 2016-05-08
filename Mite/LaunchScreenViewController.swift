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
        self.performSegueWithIdentifier("launchSegue", sender: self)
    }
}
