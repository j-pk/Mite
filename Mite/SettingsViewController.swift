//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var nsfwLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        
        UIView.transitionWithView(backgroundView, duration:0.4, options: nil, animations: {
                
            self.backgroundView.alpha = 0.85
            self.view.alpha = 0.85
                
            }, completion: nil)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            
            self.settingsLabel.alpha = 1
            self.nsfwLabel.alpha = 1
            self.switchButton.alpha = 1
            self.dividerView.alpha = 1
            self.dismissButton.alpha = 1
            
            }) { (finished) -> Void in
                
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.backgroundView.alpha = 0
        self.settingsLabel.alpha = 0
        self.nsfwLabel.alpha = 0
        self.switchButton.alpha = 0
        self.dividerView.alpha = 0
        self.dismissButton.alpha = 0
        self.view.alpha = 0
        
        switchButton.setOn(menuDefaults.boolForKey("nsfwFilterDefault"), animated: false)

    }
    
    
    @IBAction func switchButtonPressed(sender: UISwitch) {
        
        if switchButton.on == true {
            
            menuDefaults.setBool(true, forKey: "nsfwFilterDefault")
            menuDefaults.synchronize()
            println("This is true value \(switchButton.on)")

        } else {
            
            menuDefaults.setBool(false, forKey: "nsfwFilterDefault")
            menuDefaults.synchronize()
            println("This is false value \(switchButton.on)")
        }
        
    }

    @IBAction func dismissButtonPressed(sender: UIButton) {
        
        UIView.transitionWithView(backgroundView, duration: 0.4, options: nil, animations: { () -> Void in
            
            self.settingsLabel.alpha = 0
            self.nsfwLabel.alpha = 0
            self.switchButton.alpha = 0
            self.dividerView.alpha = 0
            self.dismissButton.alpha = 0
            
        }) { (finished) -> Void in
            
            self.dismissViewControllerAnimated(false, completion: nil)

        }
        
    }
}

