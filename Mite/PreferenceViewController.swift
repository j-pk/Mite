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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.tintColor = UIColor.whiteColor()
        self.titleLabel.alpha = 0
        self.nsfwLabel.alpha = 0
        self.userPreferencesTextView.alpha = 0
        self.nsfwSwitch.alpha = 0
        self.cancelButton.alpha = 0
        self.dividerView.alpha = 0
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
        })
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        UIView.transitionWithView(self.view, duration: 0.4, options: [], animations: { () -> Void in
            self.titleLabel.alpha = 0
            self.nsfwLabel.alpha = 0
            self.userPreferencesTextView.alpha = 0
            self.nsfwSwitch.alpha = 0
            self.cancelButton.alpha = 0
            self.dividerView.alpha = 0
        }) { (finished) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func loadPreferences() {
        guard let user = NetworkManager.sharedInstance.redditUserPreference else { return }
        self.titleLabel.text = user.name + " Preferences"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        let date = dateFormatter.stringFromDate(user.created)
        
        self.userPreferencesTextView.text =
            "Over 18 - \(user.over_18)\n" +
            "Date Created - \(date)\n" +
            "Has Verified Email - \(user.hasVerifiedEmail)\n" +
            "Gold - \(user.isGold)\n" +
            "Mod - \(user.isMod)\n" +
            "Link Karma - \(user.linkKarma)"
    }
}
