//
//  DataManager.swift
//  Mite
//
//  Created by jpk on 4/28/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    static let sharedInstance = DataManager()
    
    var miteImages = [MiteImage]()
    
    func fetchAPIData(paginate paginate: Bool, completion: (([MiteImage]) -> ())?) {
        let requestCount = 15
        var fullURL = redditAPI + NetworkManager.sharedInstance.searchRedditString + ".json"
        
        if paginate {
            if let pageAfter = self.miteImages.last?.pageAfter {
                fullURL += "?limit=\(requestCount)&after=\(pageAfter)"
            }
        }
        
        NetworkManager.sharedInstance.requestImages(fullURL) { (data) in
            if !paginate {
                self.miteImages = data
            } else {
                data.forEach({ self.miteImages.append($0) })
            }
            completion?(data)
        }
        //NotificationManager.sharedInstance.showNotificationWithTitle("Balls", notificationType: NotificationType.Message, timer: 4.0)
    }
    
    func saveImage(data:Dictionary<String, AnyObject>, moc:NSManagedObjectContext? = nil, save:Bool = true) {
        let moc = CoreDataStack.sharedInstance.context
        
        moc.performBlock {
            
            do {
                guard let id = data["id"] as? String else { return }
                let image = try self.fetchImage(id, moc: moc) ?? NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: moc) as? Image
                
                image?.author = data["author"] as? String
                image?.id = data["id"] as? String
                image?.over_18 = data["over_18"] as? Bool
                image?.score = data["score"] as? NSNumber
                image?.subreddit = data["subreddit"] as? String
                image?.title = data["title"] as? String
                image?.url = data["url"] as? String
                image?.imageURL = data["imageURL"] as? String
                image?.pageAfter = data["pageAfter"] as? String
                                
                if save {
                    try moc.save()
                }
                
            } catch let error as NSError {
                CoreDataStack.sharedInstance.handleError(error)
            }
        }
    }
    
    func saveImages(data:[Dictionary<String, AnyObject>]) {
        let moc = CoreDataStack.sharedInstance.context
        for image in data {
            self.saveImage(image, moc: moc, save: false)
        }
        
        moc.performBlock {
            do {
                try moc.save()
            } catch let error as NSError {
                CoreDataStack.sharedInstance.handleError(error)
            }
        }
    }
    
    private func fetchImage(id:String, moc:NSManagedObjectContext) throws -> Image? {
        do {
            guard let image = try CoreDataStack.sharedInstance.fetch("Image", predicate: NSPredicate(format: "id = %@",id), fetchLimit: 1, moc: moc) as? [Image] else { return nil }
            return image.first
        } catch let error as NSError {
            throw error
        }
    }
}