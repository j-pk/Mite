//
//  PreferenceViewController.swift
//  Mite
//
//  Created by jpk on 5/22/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userPreferencesTextView: UITextView!
    @IBOutlet weak var nsfwLabel: UILabel!
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var labelNSFW: UILabel!
    @IBOutlet weak var labelNSFWSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.tintColor = UIColor.whiteColor()
        self.titleLabel.alpha = 0
        self.nsfwLabel.alpha = 0
        self.userPreferencesTextView.alpha = 0
        self.nsfwSwitch.alpha = 0
        self.cancelButton.alpha = 0
        self.dividerView.alpha = 0
        self.labelNSFWSwitch.alpha = 0
        self.labelNSFW.alpha = 0
        self.view.alpha = 0
        self.loadPreferences()
    }
    

    override func viewDidAppear(animated: Bool) {
        UIView.transitionWithView(self.view, duration:0.4, options: [], animations: {
            self.view.alpha = 0.85
        }, completion: nil)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.titleLabel.alpha = 1
            self.nsfwLabel.alpha = 1
            self.userPreferencesTextView.alpha = 1
            self.nsfwSwitch.alpha = 1
            self.cancelButton.alpha = 1
            self.dividerView.alpha = 1
            self.labelNSFWSwitch.alpha = 1
            self.labelNSFW.alpha = 1
        })
        self.configurePreferences()
    }
    
    @IBAction func nsfwSwitch(sender: AnyObject) {

    }
    
    @IBAction func labelNSFWSwitch(sender: AnyObject) {
    
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        UIView.transitionWithView(self.view, duration: 0.4, options: [], animations: { () -> Void in
            self.titleLabel.alpha = 0
            self.nsfwLabel.alpha = 0
            self.userPreferencesTextView.alpha = 0
            self.nsfwSwitch.alpha = 0
            self.cancelButton.alpha = 0
            self.dividerView.alpha = 0
            self.labelNSFWSwitch.alpha = 0
            self.labelNSFW.alpha = 0
        }) { (finished) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func configurePreferences() {
        self.nsfwSwitch.on = false
        self.labelNSFWSwitch.on = false
        
        guard let user = NetworkManager.sharedInstance.redditUser else { return }
        if !user.over_18 {
            self.nsfwLabel.enabled = false
            self.nsfwSwitch.enabled = false
            self.labelNSFW.enabled = false
            self.labelNSFWSwitch.enabled = false
        }
        
        guard let pref = NetworkManager.sharedInstance.redditUserPreferences else { return }
        if pref.over_18 {
            self.nsfwSwitch.on = true
        }
        if pref.label_nsfw {
            self.labelNSFWSwitch.on = true
        }
    }
    
    func loadPreferences() {
        guard let user = NetworkManager.sharedInstance.redditUser else { return }
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
