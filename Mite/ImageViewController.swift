//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import Gifu

protocol VoteStateForImageDelegate: class {
    func voteState(id: String, state: Bool?)
}

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
    
    var cell: MiteCollectionViewCell!
    var cellYOffset: CGFloat = 0
    weak var delegate: VoteStateForImageDelegate?
    
    var detailImage: UIImage?
    var detailTitle: String?
    var upvoteCount: String?
    var imageURLToShare: String?
    var imageURL: String?
    var imageIDToVote: String?
    var media: Bool = false
    var buttonState: Bool?
    var lastLocation:CGPoint = CGPointMake(0, 0)
    var animator: UIDynamicAnimator!
    
    var once: dispatch_once_t = 0
    var upvoted = false
    var downvoted = false
    
    //MARK: Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        if media {
            self.loadAndAnimateGifs()
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.resizeImage))
        
        //listens for gesture
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(pan)
        
        self.animator = UIDynamicAnimator(referenceView: view)
        if buttonState == true {
            self.upvoteButton.setImage(UIImage(named: "upvoteRed"), forState: .Normal)
            self.upvoted = true
        } else if buttonState == false {
            self.downvoteButton.setImage(UIImage(named: "downvoteRed"), forState: .Normal)
            self.downvoted = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.detailImageView.center = CGPointMake(self.cell.center.x, self.cell.center.y + self.cellYOffset)
        
        UIView.transitionWithView(detailImageView, duration:0.4, options: [],
                                  animations: {
                                    self.detailImageView.center = self.backgroundImageView.center
                                    self.detailImageView.transform = CGAffineTransformIdentity
            }, completion: nil)
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.backgroundImageView.alpha = 1
            }, completion: nil)
    }
    
    
    func configureView() {
        self.backgroundImageView.alpha = 0
        
        if let imageURL = self.imageURL, detailTitle = self.detailTitle, upvoteCount = self.upvoteCount, url = self.imageURLToShare, imageID = self.imageIDToVote {
            NetworkManager.sharedInstance.fetchImage(fromUrl: imageURL) { (image) in
                self.detailImageView.image = image
            }
            self.titleTextView.text = detailTitle
            self.upvoteCountLabel.text = upvoteCount
            self.imageURLToShare = url
            self.imageIDToVote = imageID
    
            let size = titleTextView.sizeThatFits(CGSize(width: view.frame.width - 40, height: 500))
            titleHeight.constant = size.height
        }
        
        let scale = self.cell.frame.width / self.detailImageView.frame.width
        self.detailImageView.transform = CGAffineTransformMakeScale(scale, scale)
        self.detailImageView.backgroundColor = UIColor.clearColor()
    }
    
    //MARK: Buttons Pressed
    
    func removeVote(sender: UIButton? = nil, imageId: String) {
        Alamofire.request(Router.UpvoteAndDownvote(linkName: imageId, direction: 0)).responseJSON { response in
            switch response.result {
            case .Success:
                NotificationManager.sharedInstance.showNotificationWithTitle("Removed vote", notificationType: NotificationType.Message, timer: 1.0)
                if let sender = self.downvoteButton where sender == self.downvoteButton {
                    sender.setImage(UIImage(named: "downvoteWhite"), forState: .Normal)
                }
                if let sender = self.upvoteButton where sender == self.upvoteButton {
                    sender.setImage(UIImage(named: "upvoteWhite"), forState: .Normal)
                }
                if sender == nil {
                    self.upvoteButton.setImage(UIImage(named: "upvoteWhite"), forState: .Normal)
                    self.downvoteButton.setImage(UIImage(named: "downvoteWhite"), forState: .Normal)
                }
                if let delegate = self.delegate {
                    delegate.voteState(imageId, state: nil)
                }
            case .Failure(let error):
                NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                print(error)
            }
        }
    }
    
    @IBAction func upvoteButtonPressed(sender: UIButton) {
        if let imageID = imageIDToVote {
            if self.upvoted {
                self.removeVote(sender, imageId: imageID)
                self.upvoted = false
                return
            } else if self.downvoted == true && self.upvoted == false {
                self.removeVote(nil, imageId: imageID)
                self.downvoted = false; self.upvoted = false
                return
            }
            Alamofire.request(Router.UpvoteAndDownvote(linkName: imageID, direction: 1)).responseJSON { response in
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Upvoted Successfully", notificationType: NotificationType.Upvote, timer: 1.0)
                    self.upvoteButton.setImage(UIImage(named: "upvoteRed"), forState: .Normal)
                    self.upvoted = true
                    if let delegate = self.delegate {
                        delegate.voteState(imageID, state: true)
                    }
                case .Failure(let error):
                    NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                    print(error)
                }
            }
        }
    }
    
    @IBAction func downvoteButtonPressed(sender: UIButton) {
        if let imageID = imageIDToVote {
            if self.downvoted {
                self.removeVote(sender, imageId: imageID)
                self.downvoted = false
                return
            } else if self.downvoted == false && self.upvoted == true {
                self.removeVote(nil, imageId: imageID)
                self.downvoted = false; self.upvoted = false
                return
            }
            Alamofire.request(Router.UpvoteAndDownvote(linkName: imageID, direction: -1)).responseJSON { response in
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Downvoted Successfully", notificationType: NotificationType.Downvote, timer: 1.0)
                    self.downvoteButton.setImage(UIImage(named: "downvoteRed"), forState: .Normal)
                    self.downvoted = true
                    if let delegate = self.delegate {
                        delegate.voteState(imageID, state: false)
                    }
                case .Failure(let error):
                    NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                    print(error)
                }
            }
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        let actionSheetController = UIAlertController(title: "Share", message: "", preferredStyle: .ActionSheet)
        
        let copyImage = UIAlertAction(title: "Copy Image", style: .Default) { (action) -> Void in
            if let image = self.detailImage {
                UIPasteboard.generalPasteboard().image = image
            }
            self.showProgressHUD()
        }
        
        let copyURL = UIAlertAction(title: "Copy Image URL", style: .Default) { (action) -> Void in
            if let url = self.imageURLToShare {
                UIPasteboard.generalPasteboard().string = url
            }
            self.showProgressHUD()
        }
        
        let saveImage = UIAlertAction(title: "Save Image to Camera Roll", style: .Default) { (action) -> Void in
            if let image = self.detailImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            self.showProgressHUD()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheetController.addAction(copyImage)
        actionSheetController.addAction(copyURL)
        actionSheetController.addAction(saveImage)
        actionSheetController.addAction(cancel)
        
        presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func showProgressHUD() {
        let progressHUD = ProgressIndicator(text: "Copied")
        self.view.addSubview(progressHUD)
        self.view.center = progressHUD.center
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            progressHUD.show()
            }, completion: { (finished) -> Void in
                delay(0.5) {
                    progressHUD.hidden = true
                }
        })
    }
    
    func loadAndAnimateGifs() {
        guard let url = self.imageURLToShare else { return }
        if url.hasSuffix("mp4") {
            let videoURL = NSURL(string: url)
            let player = AVPlayer(URL: videoURL!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.detailImageView.layer.addSublayer(playerLayer)
            player.play()
            NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
                player.seekToTime(kCMTimeZero)
                player.play()
            }
        } else if url.hasSuffix("gif") {
            NetworkManager.sharedInstance.fetchImageData(fromUrl: url, completion: { filePath in
                let gifView = AnimatableImageView(frame: self.detailImageView.frame)
                gifView.contentMode = .ScaleAspectFit
                self.detailImageView.addSubview(gifView)
                guard let filePath = filePath else { return }
                gifView.animateWithImageData(filePath)
                delay(0.5) {
                    gifView.startAnimatingGIF()
                }
            })
        }
    }
    
    //MARK: Gestures
    
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
                }, completion: nil)
            
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
            
            }, completion: nil)
        
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
}
