//
//  NotificationView.swift
//  Mite
//
//  Created by jpk on 5/3/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import UIKit


enum NotificationType {
    case Success
    case Error
    case Warning
    case Message
    case Upvote
    case Downvote
    
    var color:UIColor {
        switch self {
        case .Success:
            return UIColor(red:0.29, green:0.9, blue:0.49, alpha:1)
        case .Error:
            return UIColor(red:1, green:0.16, blue:0, alpha:1)
        case .Warning:
            return UIColor(red:1, green:0.95, blue:0.78, alpha:1)
        case .Message:
            return UIColor(red:0.54, green:0.48, blue:0.48, alpha:1)
        case .Upvote:
            return UIColor(red:1, green:0.18, blue:0, alpha:1)
        case .Downvote:
            return UIColor(red:0.62, green:0.02, blue:0.1, alpha:1)
        }
    }
}

class NotificationView: UIView {
    var title = ""
    var referenceView = UIView()
    var showNotificationUnderNavigationBar = false
    var animator = UIDynamicAnimator()
    var gravity = UIGravityBehavior()
    var collision = UICollisionBehavior()
    var itemBehavior = UIDynamicItemBehavior()
    var notificationType = NotificationType.Success
    let notificationViewHeight: CGFloat = 66
    var timer = NSTimeInterval()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(title: String, referenceView: UIView, notificationType: NotificationType, timer: NSTimeInterval) {
        self.title = title
        self.referenceView = referenceView
        self.notificationType = notificationType
        self.timer = timer
        super.init(frame: CGRectMake(0, 0, referenceView.bounds.size.width, notificationViewHeight))
        setup()
    }
    
    override func drawRect(rect: CGRect) {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.20
        self.layer.shadowOffset = CGSizeMake(0, 2.0)
        self.layer.shadowRadius = 2.0
    }
    
    func hideNotification() {
        animator.removeBehavior(gravity)
        gravity = UIGravityBehavior(items: [self])
        gravity.gravityDirection = CGVectorMake(0, -1)
        animator.addBehavior(gravity)
    }
    
    func applyDynamics() {
        let boundaryYAxis: CGFloat = showNotificationUnderNavigationBar == true ? 2 : 1
        animator = UIDynamicAnimator(referenceView: referenceView)
        gravity = UIGravityBehavior(items:[self])
        collision = UICollisionBehavior(items: [self])
        itemBehavior = UIDynamicItemBehavior(items: [self])
        
        itemBehavior.elasticity = 0.4
        
        collision.addBoundaryWithIdentifier("NotificationBoundary", fromPoint: CGPointMake(0, self.bounds.size.height * boundaryYAxis), toPoint: CGPointMake(referenceView.bounds.size.width,self.bounds.size.height * boundaryYAxis))
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(itemBehavior)
        
        NSTimer.scheduledTimerWithTimeInterval(timer, target: self, selector: #selector(hideNotification), userInfo: nil, repeats: false)
    }
    
    func setup() {
        let swipeAwayGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAway))
        swipeAwayGestureRecognizer.direction = .Up
        
        self.addGestureRecognizer(swipeAwayGestureRecognizer)
        
        let screenBounds = UIScreen.mainScreen().bounds
        self.frame = CGRectMake(0, showNotificationUnderNavigationBar == true ? 1 : -1 * notificationViewHeight, screenBounds.size.width, notificationViewHeight)
        
        setupNotificationType()
        
        let labelRect = CGRectMake(referenceView.frame.minX, 10, screenBounds.size.width, notificationViewHeight)
        
        let titleLabel = UILabel(frame: labelRect)
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "HelveticaNeue-SemiBold", size: 8)
        titleLabel.textColor = UIColor.whiteColor()
        
        addSubview(titleLabel)
    }
    
    func swipeAway(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Up {
            self.hideNotification()
        }
    }
    
    func setupNotificationType() {
        switch notificationType {
        case .Success:
            backgroundColor = notificationType.color
        case .Error:
            backgroundColor = notificationType.color
        case .Warning:
            backgroundColor = notificationType.color
        case .Message:
            backgroundColor = notificationType.color
        case .Upvote:
            backgroundColor = notificationType.color
        case .Downvote:
            backgroundColor = notificationType.color
        }
    }
}