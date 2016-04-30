//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    var cell: MainCollectionViewCell!
    var cellYOffset: CGFloat = 0
    
    var detailImage: UIImage?
    var detailTitle: String?
    var upvoteCount: String?
    var imageURLToShare: String?
    var imageURL: String?
    var imageIDToVote: String?
    var lastLocation:CGPoint = CGPointMake(0, 0)
    var animator: UIDynamicAnimator!
    
    var once: dispatch_once_t = 0
    var pressedUp = false
    var pressedDown = false
    
    ////////////////////MARK: Load
    
    override func viewDidAppear(animated: Bool) {
        
        self.detailImageView.center = CGPointMake(self.cell.center.x, self.cell.center.y + self.cellYOffset)
        
        UIView.transitionWithView(detailImageView, duration:0.4, options: [],
            animations: {
                
                self.detailImageView.center = self.backgroundImageView.center
                self.detailImageView.transform = CGAffineTransformIdentity
                
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            
            self.backgroundImageView.alpha = 1
            
            }) { (finished) -> Void in
                
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.resizeImage))
                
        //listens for gesture
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(pan)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        self.backgroundImageView.alpha = 0
        
        if let imageURL = self.imageURL {
            NetworkManager.sharedInstance.fetchImage(fromUrl: imageURL) { (image) in
                self.detailImageView.image = image
            }
        }
        
        if let detailTitle = self.detailTitle {
            titleTextView.text = detailTitle
            
            let size = titleTextView.sizeThatFits(CGSize(width: view.frame.width - 40, height: 500))
            titleHeight.constant = size.height
        }
        
        if let upvoteCount = self.upvoteCount {
            upvoteCountLabel.text = upvoteCount
        }
        
        if let imageURL = self.imageURLToShare {
            imageURLToShare = imageURL
        }
        
        if let imageID = self.imageIDToVote {
            imageIDToVote = imageID
        }
        
        let scale = self.cell.frame.width / self.detailImageView.frame.width
        self.detailImageView.transform = CGAffineTransformMakeScale(scale, scale)
        self.detailImageView.backgroundColor = UIColor.clearColor()
    }
    
    ////////////////////MARK: Gestures
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        dispatch_once(&once, { () -> Void in
            
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                
                let velocity = sender.velocityInView(self.detailImageView)
                let imagePushInstant = UIPushBehavior(items: [self.detailImageView], mode: UIPushBehaviorMode.Instantaneous)
                imagePushInstant.pushDirection = CGVectorMake(velocity.x * 0.7, velocity.y * 0.7)
                imagePushInstant.setTargetOffsetFromCenter(UIOffsetMake(-400, 400), forItem: self.detailImageView)
                imagePushInstant.active = true
                
                self.animator.removeAllBehaviors()
                self.animator.addBehavior(imagePushInstant)
                
                }) { (finished) -> Void in
                    
            }
            
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                
                self.detailImageView.alpha = 0
                self.backgroundImageView.alpha = 0
                
                }, completion: { (finished) -> Void in
                    
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
            })
            
        })
        
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: [], animations: { () -> Void in
            
            let scale = self.cell.frame.width / self.detailImageView.frame.width
            
            self.detailImageView.transform = CGAffineTransformMakeScale(scale, scale)
            self.detailImageView.center = CGPointMake(self.cell.center.x, self.cell.center.y + self.cellYOffset)
            
            }) { (finished) -> Void in
                
        }
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            
            self.detailImageView.alpha = 0
            self.backgroundImageView.alpha = 0
            
            }, completion: { (finished) -> Void in
                
                self.dismissViewControllerAnimated(false, completion: nil)
                
        })
    }
    
    func resizeImage(scale: UIPinchGestureRecognizer) {
        
        if scale.state == .Ended || scale.state == .Changed {
            
            let currentScale = detailImageView.frame.size.width / detailImageView.bounds.size.width
            let newScale = currentScale * scale.scale
            let transform = CGAffineTransformMakeScale(newScale, newScale);
            detailImageView.transform = transform
            scale.scale = 1
            
        }
        
    }
    
    ////////////////////MARK: Buttons Pressed
    
    @IBAction func upvoteButtonPressed(sender: UIButton) {
        
        if let imageID = imageIDToVote {
         
            imageIDToVote = imageID
            
            NetworkManager.sharedInstance.upvoteAndDownvote(imageID, direction: 1, completion: { () -> Void in
                print("upvote")
                self.upvoteButton.setImage(UIImage(named: "upvoteWhiteSelected"), forState: .Normal)
                self.pressedUp = true
                print("This should be true UP \(self.pressedUp)")
                
            })
            
            if pressedDown == true {
                NetworkManager.sharedInstance.upvoteAndDownvote(imageID, direction: 0, completion: { () -> Void in
                    
                    self.downvoteButton.setImage(UIImage(named: "downvoteWhite"), forState: .Normal)
                    self.upvoteButton.setImage(UIImage(named: "upvoteWhite"), forState: .Normal)
                    self.pressedUp = false
                    self.pressedDown = false
                    print("This should be false UP \(self.pressedUp)")
                    
                })
            
            }
            
        }
        
    }
    
    @IBAction func downvoteButtonPressed(sender: UIButton) {
        
        if let imageID = imageIDToVote {
            
            imageIDToVote = imageID
            
            NetworkManager.sharedInstance.upvoteAndDownvote(imageID, direction: -1, completion: { () -> Void in
                
                print("downvote")
                self.downvoteButton.setImage(UIImage(named: "downvoteWhiteSelected"), forState: .Normal)
                self.pressedDown = true
                print("This should be true DOWN \(self.pressedDown)")
                
            })
            
            if pressedUp == true {
                
                NetworkManager.sharedInstance.upvoteAndDownvote(imageID, direction: 0, completion: { () -> Void in
                    
                    self.downvoteButton.setImage(UIImage(named: "downvoteWhite"), forState: .Normal)
                    self.upvoteButton.setImage(UIImage(named: "upvoteWhite"), forState: .Normal)
                    self.pressedDown = false
                    self.pressedUp = false
                    print("This should be false DOWN \(self.pressedDown)")
                    
                })
                
            }
            
        }
        
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        
        let progressHUD = ProgressIndicator(text: "Copied")
        
        let actionSheetController = UIAlertController(title: "Share", message: "", preferredStyle: .ActionSheet)
        
        let copyImage = UIAlertAction(title: "Copy Image", style: .Default) { (action) -> Void in
            
            if let image = self.detailImage {
            
                UIPasteboard.generalPasteboard().image = image
            }
            
            self.view.addSubview(progressHUD)
            self.view.center = progressHUD.center
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                
                progressHUD.show()
                
            }, completion: { (finished) -> Void in
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5*Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                    progressHUD.hidden = true
                
                }
                
            })
        
        }
        
        
        let copyURL = UIAlertAction(title: "Copy Image URL", style: .Default) { (action) -> Void in
            
            if let url = self.imageURLToShare {
                
                UIPasteboard.generalPasteboard().string = url
            }
            
            self.view.addSubview(progressHUD)
            self.view.center = progressHUD.center
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                
                progressHUD.show()
                
            }, completion: { (finished) -> Void in
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5*Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    
                    progressHUD.hidden = true
                    
                }
            })
            
        }
        
        let saveImage = UIAlertAction(title: "Save Image to Camera Roll", style: .Default) { (action) -> Void in
            
            if let image = self.detailImage {
               
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
               
            }
            
            self.view.addSubview(progressHUD)
            self.view.center = progressHUD.center
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                
                progressHUD.show()
                
                }, completion: { (finished) -> Void in
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5*Double(NSEC_PER_SEC)))
                    
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        
                        progressHUD.hidden = true
                        
                    }
                    
            })
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheetController.addAction(copyImage)
        actionSheetController.addAction(copyURL)
        actionSheetController.addAction(saveImage)
        actionSheetController.addAction(cancel)
        
        presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
}
