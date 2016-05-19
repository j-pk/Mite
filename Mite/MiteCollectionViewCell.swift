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
    
    weak var delegate: VoteStateForImageDelegate?
    var imageId: String?
    var voted: Bool = false
    
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
        self.mainImageView.af_setImageWithURL(NSURL(string: data.modifiedURL)!, placeholderImage: UIImage(named: "placeholder"))
        self.imageId = data.id
        
        let media = data.mediaBool
        if media == true {
            self.mediaViewIcon.hidden = false
        } else {
            self.mediaViewIcon.hidden = true 
        }
        
        let over18 = data.over_18
        if over18 == true {
            let filter = BlurFilter(blurRadius: 20)
            //self.mainImageView.image = nil
            //self.mainImageView.af_cancelImageRequest()
            self.mainImageView.af_setImageWithURL(
                NSURL(string: data.modifiedURL)!,
                placeholderImage: UIImage(named: "placeholder"),
                filter: filter
            )
            //self.hidden = true
            self.nsfwLabel.hidden = false
            self.userInteractionEnabled = false
            ()
        } else {
            self.hidden = false
            self.userInteractionEnabled = true
        }
        self.setNeedsDisplay()
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
            self.pressingUp = true
            self.pressingDown = false
            if self.pressingUp == true && self.voted == true {
                self.removeVote(imageId)
                return
            }
            Alamofire.request(Router.UpvoteAndDownvote(linkName: imageId, direction: 1)).responseJSON { response in
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Upvoted Successfully", notificationType: NotificationType.Upvote, timer: 1.0)
                    if let delegate = self.delegate {
                        delegate.voteState(imageId, state: true)
                    }
                    self.voted = true
                case .Failure(let error):
                    NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                    print(error)
                }
            }
        } else if point < -20 {
            self.pressingDown = true
            self.pressingUp = false
            if self.pressingDown == true && self.voted == true {
                self.removeVote(imageId)
                return
            }
            Alamofire.request(Router.UpvoteAndDownvote(linkName: imageId, direction: -1)).responseJSON { response in
                switch response.result {
                case .Success:
                    NotificationManager.sharedInstance.showNotificationWithTitle("Downvoted Successfully", notificationType: NotificationType.Downvote, timer: 1.0)
                    if let delegate = self.delegate {
                        delegate.voteState(imageId, state: true)
                    }
                    self.voted = true
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
                self.voted = false
            case .Failure(let error):
                NotificationManager.sharedInstance.showNotificationWithTitle("Error: \(error)", notificationType: NotificationType.Message, timer: 2.0)
                print(error)
            }
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
