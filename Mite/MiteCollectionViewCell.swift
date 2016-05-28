//
//  MiteCollectionViewCell.swift
//  Mite
//
//  Created by Jameson Kirby on 4/30/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MiteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var mediaViewIcon: MediaView!
    @IBOutlet weak var nsfwLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    
    weak var delegate: VoteStateForImageDelegate?
    var imageId: String?
    var state: Bool?
    
    var pressingUp = false {
        didSet{
            pressingUp ? upvoteButton.setImage(UIImage(named: "upvoteSelected"), forState: .Normal) : upvoteButton.setImage(UIImage(named: "upvote"), forState: .Normal)
        }
    }
    
    var pressingDown = false {
        didSet {
            pressingDown ? downvoteButton.setImage(UIImage(named: "downvoteSelected"), forState: .Normal) : downvoteButton.setImage(UIImage(named: "downvote"), forState: .Normal)
        }
    }
    
    func configureCell(data: MiteImage) {
        self.backgroundColor = UIColor.clearColor()
        self.upvoteButton.hidden = true
        self.downvoteButton.hidden = true
        self.nsfwLabel.hidden = true
        self.filterView.hidden = true
        self.mainImageView.af_setImageWithURL(NSURL(string: data.modifiedURL)!, placeholderImage: UIImage(named: "placeholder"))
        self.imageId = data.id
        
        let media = data.mediaBool
        if media == true {
            self.mediaViewIcon.hidden = false
        } else {
            self.mediaViewIcon.hidden = true 
        }
        self.determineNSFW(data)
        self.setNeedsDisplay()
    }
    
    func determineNSFW(data: MiteImage) {
        let over18 = data.over_18
        if let preferences = NetworkManager.sharedInstance.redditUserPreferences {
            if preferences.label_nsfw && over18 == true {
                self.nsfwLabel.hidden = false
                self.filterView.hidden = false
                self.filterView.layer.opacity = 1.0
            }
            if preferences.over_18 && over18 == true {
                self.userInteractionEnabled = true
            }
        } else {
            if over18 == true {
                self.nsfwLabel.hidden = false
                self.filterView.hidden = false
                self.filterView.layer.opacity = 1.0
                self.userInteractionEnabled = false
            } 
        }
    }
    
    func longPressCellView(transform: CGAffineTransform, alpha: CGFloat) {
        self.center = self.center
        self.transform = transform
        self.alpha = alpha
    }
    
    func initialGestureState() {
        self.upvoteButton.hidden = false
        self.downvoteButton.hidden = false
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.4
        
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.longPressCellView(CGAffineTransformMakeScale(1.05, 1.05), alpha: 1.0)
        })
    }
    
    func cellDetectGesture(point: CGFloat) {
        if point > 20 {
            self.pressingUp = true
            self.pressingDown = false
        } else if point < -20 {
            self.pressingDown = true
            self.pressingUp = false
        }
    }
    
    func cellVote(point: CGFloat) {
        guard let imageId = self.imageId else { return }
        if point > 20 {
             if self.state == true && self.pressingUp == true  {
                self.removeVote(imageId)
                return
            }
            self.pressingUp = true
            self.pressingDown = false
            Alamofire.request(Router.UpvoteAndDownvote(linkName: imageId, direction: 1)).responseJSON { response in
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Upvoted Successfully", notificationType: NotificationType.Upvote, timer: 1.0)
                    if let delegate = self.delegate {
                        delegate.voteState(imageId, state: true)
                    }
                case .Failure(let error):
                    NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                    print(error)
                }
            }
        } else if point < -20 {
            if self.state == false && self.pressingDown == true {
                self.removeVote(imageId)
                return
            }
            self.pressingDown = true
            self.pressingUp = false
            Alamofire.request(Router.UpvoteAndDownvote(linkName: imageId, direction: -1)).responseJSON { response in
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Downvoted Successfully", notificationType: NotificationType.Downvote, timer: 1.0)
                    if let delegate = self.delegate {
                        delegate.voteState(imageId, state: false)
                    }
                case .Failure(let error):
                    NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                    print(error)
                }
            }
        }
    }
    
    func removeVote(imageId: String) {
        Alamofire.request(Router.UpvoteAndDownvote(linkName: imageId, direction: 0)).responseJSON { response in
            switch response.result {
            case .Success:
                NotificationManager.sharedInstance.showNotificationWithTitle("Removed vote", notificationType: NotificationType.Message, timer: 1.0)
                self.pressingUp = false
                self.pressingDown = false
                if let delegate = self.delegate {
                    delegate.voteState(imageId, state: nil)
                }
            case .Failure(let error):
                NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                print(error)
            }
        }
    }
    
    func setVoteState(state: Bool?) {
        if state == true {
            self.pressingUp = true
        } else if state == false {
            self.pressingDown = true
        } else {
            self.pressingUp = false
            self.pressingDown = false
        }
    }
    
    func resetCell() {
        self.upvoteButton.hidden = true
        self.downvoteButton.hidden = true
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.longPressCellView(CGAffineTransformIdentity, alpha: 1.0)
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.layer.shadowRadius = 0.0
            self.layer.shadowOpacity = 0.0
        })
    }
    
}
