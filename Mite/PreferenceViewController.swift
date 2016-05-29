//
//  PreferenceViewController.swift
//  Mite
//
//  Created by jpk on 5/22/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PreferenceViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userPreferencesTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var labelNSFW: UILabel!
    @IBOutlet weak var labelNSFWSwitch: UISwitch!
    
    var user: User?
    var preferences: Preferences?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurePreferences()
        self.cancelButton.tintColor = UIColor.whiteColor()
        self.titleLabel.alpha = 0
        self.userPreferencesTextView.alpha = 0
        self.cancelButton.alpha = 0
        self.dividerView.alpha = 0
        self.labelNSFWSwitch.alpha = 0
        self.labelNSFW.alpha = 0
        self.view.alpha = 0
        self.labelNSFWSwitch.enabled = false 
    }
    

    override func viewDidAppear(animated: Bool) {
        UIView.transitionWithView(self.view, duration:0.4, options: [], animations: {
            self.view.alpha = 0.85
        }, completion: nil)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.titleLabel.alpha = 1
            self.userPreferencesTextView.alpha = 1
            self.cancelButton.alpha = 1
            self.dividerView.alpha = 1
            self.labelNSFWSwitch.alpha = 1
            self.labelNSFW.alpha = 1
        })
    }
    
    @IBAction func labelNSFWSwitch(sender: UISwitch) {
        print(labelNSFWSwitch.on)
        if labelNSFWSwitch.on {
            NetworkManager.sharedInstance.patchLabelNSFWPreference(true)
        } else {
            NetworkManager.sharedInstance.patchLabelNSFWPreference(false)
        }
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        UIView.transitionWithView(self.view, duration: 0.4, options: [], animations: { () -> Void in
            self.titleLabel.alpha = 0
            self.userPreferencesTextView.alpha = 0
            self.cancelButton.alpha = 0
            self.dividerView.alpha = 0
            self.labelNSFWSwitch.alpha = 0
            self.labelNSFW.alpha = 0
        }) { (finished) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func configurePreferences() {
        self.labelNSFWSwitch.on = false
        if let pref = preferences {
            if pref.label_nsfw {
                self.labelNSFWSwitch.on = true
            }
        }
        
        if let user = user {
            if !user.over_18 {
                self.labelNSFW.enabled = false
                self.labelNSFWSwitch.enabled = false
            }
            
            self.titleLabel.text = user.name + " Preferences"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .LongStyle
            let date = dateFormatter.stringFromDate(user.created)
            
            self.userPreferencesTextView.text =
                "Date Created - \(date)\n" +
                "Has Verified Email - \(user.hasVerifiedEmail)\n" +
                "Gold - \(user.isGold)\n" +
                "Mod - \(user.isMod)\n" +
                "Over 18 - \(user.over_18)\n" +
                "Link Karma - \(user.linkKarma)"
        }
    }
}
