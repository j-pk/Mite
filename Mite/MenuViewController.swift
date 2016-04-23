//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var subredditSearch: UISearchBar!
    @IBOutlet weak var popularSubredditsLabel: UILabel!
    @IBOutlet weak var picsButton: UIButton!
    @IBOutlet weak var awwButton: UIButton!
    @IBOutlet weak var funnyButton: UIButton!
    @IBOutlet weak var iTookAPictureButton: UIButton!
    @IBOutlet weak var artButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var customizeLabel: UILabel!
   
    var firstButton: String!
    var secondButton: String!
    var thirdButton: String!
    var fourthButton: String!
    var fifthButton: String!
    var subreddit = "r/"
    
    var pressedButton: UIButton?
    var arrayOfButtons = [UIButton]()
    
    @IBOutlet weak var rightSpacing: NSLayoutConstraint!
    
    ////////////////////MARK: Load
    
    override func viewWillAppear(animated: Bool) {
        
        if (HTTPRequest.session().token?.isEmpty != nil) {
            
            loginButton.setTitle("Logout", forState: .Normal)
            
        } else {
            
            loginButton.setTitle("Login", forState: .Normal)
            
        }
        
        HTTPRequest.session().getUserIdentity { () -> Void in
            
            self.userNameLabel.text = "\(HTTPRequest.session().redditUserName)"
            
        }
        
        if (menuDefaults.objectForKey("buttonOneDefault") as? String) != nil {
            
            self.firstButton = menuDefaults.objectForKey("buttonOneDefault") as? String
            
            picsButton.setTitle(self.firstButton, forState: .Normal)
    
        }
        
        if (menuDefaults.objectForKey("buttonTwoDefault") as? String) != nil {
            
            self.secondButton = menuDefaults.objectForKey("buttonTwoDefault") as? String
            
            awwButton.setTitle(self.secondButton, forState: .Normal)
            
        }
        
        if (menuDefaults.objectForKey("buttonThreeDefault") as? String) != nil {
            
            self.thirdButton = menuDefaults.objectForKey("buttonThreeDefault") as? String
            
            funnyButton.setTitle(self.thirdButton, forState: .Normal)
            
        }
        
        if (menuDefaults.objectForKey("buttonFourDefault") as? String) != nil {
            
            self.fourthButton = menuDefaults.objectForKey("buttonFourDefault") as? String
            
            iTookAPictureButton.setTitle(self.fourthButton, forState: .Normal)
            
        }
        
        if (menuDefaults.objectForKey("buttonFiveDefault") as? String) != nil {
            
            self.fifthButton = menuDefaults.objectForKey("buttonFiveDefault") as? String
            
            artButton.setTitle(self.fifthButton, forState: .Normal)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self.view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        arrayOfButtons = [picsButton, awwButton, funnyButton, iTookAPictureButton, artButton]
        
        for button in arrayOfButtons {
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
            button.addGestureRecognizer(longPress)
            longPress.minimumPressDuration = 0.2
            longPress.delegate = self
            
        }
        
        subredditSearch.delegate = self
        
        for subView in subredditSearch.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder =  NSAttributedString(string:NSLocalizedString("Search & Discover", comment:""),
                        attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
                    textField.backgroundColor = UIColor(red:0.3, green:0.29, blue:0.29, alpha:1)
                    textField.tintColor = UIColor(red:0.3, green:0.29, blue:0.29, alpha:1)
                    textField.textColor = UIColor.whiteColor()
                    
                }
            }
        }
        
        rightSpacing.constant = view.frame.width / 5
        
    }

    ////////////////////MARK: Button Actions
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let improperSearchString = subredditSearch.text
        let properSearchStringParts = improperSearchString?.componentsSeparatedByCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        let properSearchString = NSArray(array: properSearchStringParts!).componentsJoinedByString("")
        
        if properSearchString.isEmpty || properSearchString.characters.count <= 1 {
            
            let emptyAlert = UIAlertController(title: "mité", message: "Invalid seach parameters.", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            emptyAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
            }))
            
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        
        } else {
        
            ImageRequest.session().searchRedditString = "r/" + "\(properSearchString)"
            
            NSNotificationCenter.defaultCenter().postNotificationName("notifyToReload", object: nil)
            
            performSegueWithIdentifier("dismissMenu", sender: self)
        
        }
        
    }
    
    @IBAction func picsButtonPressed(sender: UIButton) {
        
        ImageRequest.session().searchRedditString = subreddit + firstButton
        
        NSNotificationCenter.defaultCenter().postNotificationName("notifyToReload", object: nil)
        
        performSegueWithIdentifier("dismissMenu", sender: self)
        
    }
    @IBAction func awwButtonPressed(sender: UIButton) {
        
        ImageRequest.session().searchRedditString = subreddit + secondButton
        
        NSNotificationCenter.defaultCenter().postNotificationName("notifyToReload", object: nil)
        
        performSegueWithIdentifier("dismissMenu", sender: self)
        
    }
    @IBAction func funnyButtonPressed(sender: UIButton) {
        
        ImageRequest.session().searchRedditString = subreddit + thirdButton
        
        NSNotificationCenter.defaultCenter().postNotificationName("notifyToReload", object: nil)
        
        performSegueWithIdentifier("dismissMenu", sender: self)
        
    }
    @IBAction func iTookAPictureButtonPressed(sender: UIButton) {
        
        ImageRequest.session().searchRedditString = subreddit + fourthButton
        
        NSNotificationCenter.defaultCenter().postNotificationName("notifyToReload", object: nil)
        
        performSegueWithIdentifier("dismissMenu", sender: self)
        
    }
    @IBAction func artButtonPressed(sender: UIButton) {
        
        ImageRequest.session().searchRedditString = subreddit + fifthButton
        
        NSNotificationCenter.defaultCenter().postNotificationName("notifyToReload", object: nil)
        
        performSegueWithIdentifier("dismissMenu", sender: self)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        
        if (HTTPRequest.session().token?.isEmpty != nil) {
            
            Alert.session().loggedOutAlert()
            HTTPRequest.session().logoutAndDeleteToken()
            loginButton.setTitle("Login", forState: .Normal)
            userNameLabel.text = ""
            
        } else {
            
            if let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") {
                                
                self.presentViewController(loginVC, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    func newSubredditNameTextField(textField: UITextField!) {
        
        textField.placeholder = "Add Subreddit Name"
        
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .Ended {
        
            let alert = UIAlertController(title: "mité", message: "Change current subreddit.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler(newSubredditNameTextField)
            
            alert.addAction(UIAlertAction(title: "Dimiss", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                let alertTextField = alert.textFields![0] 
                
                let pressedButton = gesture.view as! UIButton
                
                let improperSearchString = alertTextField.text
                let properSearchStringParts = improperSearchString?.componentsSeparatedByCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
                let properSearchString = NSArray(array: properSearchStringParts!).componentsJoinedByString("")
                
                if properSearchString.isEmpty || alertTextField.text?.characters.count <= 1 {
                    
                    let emptyAlert = UIAlertController(title: "mité", message: "Please put in a valid subreddit.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                    
                    emptyAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        
                    }))
                    
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                
                } else {
                
                    if pressedButton.tag == 1 {
                        
                        self.picsButton.setTitle("\(properSearchString) ", forState: .Normal)
                        self.firstButton = properSearchString
                        menuDefaults.setValue(properSearchString, forKey: "buttonOneDefault")
                        
                    } else if pressedButton.tag == 2 {
                        
                        self.awwButton.setTitle("\(properSearchString) ", forState: .Normal)
                        self.secondButton = properSearchString
                        menuDefaults.setValue(properSearchString, forKey: "buttonTwoDefault")
                        
                    } else if pressedButton.tag == 3 {
                        
                        self.funnyButton.setTitle("\(properSearchString) ", forState: .Normal)
                        self.thirdButton = properSearchString
                        menuDefaults.setValue(properSearchString, forKey: "buttonThreeDefault")
                        
                    } else if pressedButton.tag == 4 {
                        
                        self.iTookAPictureButton.setTitle("\(properSearchString) ", forState: .Normal)
                        self.fourthButton = properSearchString
                        menuDefaults.setValue(properSearchString, forKey: "buttonFourDefault")
                        
                    } else if pressedButton.tag == 5 {
                        
                        self.artButton.setTitle("\(properSearchString) ", forState: .Normal)
                        self.fifthButton = properSearchString
                        menuDefaults.setValue(properSearchString, forKey: "buttonFiveDefault")
                    
                    }
                
                }
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
}
