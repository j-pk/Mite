//
//  NotificationManager.swift
//  Mite
//
//  Created by jpk on 5/3/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit

class NotificationManager {
    
    static let sharedInstance = NotificationManager()
    
    lazy var window:UIWindow = {
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { abort() }
        guard let window = appDelegate.window else { abort() }
        return window
    }()
    
    func showNotificationWithTitle(title: String, notificationType: NotificationType, timer: NSTimeInterval) {
        let notificationView = NotificationView(title: title, referenceView: window, notificationType: notificationType, timer: timer)
        window.addSubview(notificationView)
        notificationView.applyDynamics()
    }
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }
}