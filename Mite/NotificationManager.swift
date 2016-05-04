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
    
    func showNotificationWithTitle(title: String, controller: UIViewController, notificationType: NotificationType, timer: NSTimeInterval) {
        let notificationView = NotificationView(title: title, referenceView: controller.view, notificationType: notificationType, timer: timer)
        controller.view.addSubview(notificationView)
        notificationView.applyDynamics()
    }
}