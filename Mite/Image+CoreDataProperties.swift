//
//  Image+CoreDataProperties.swift
//  Mite
//
//  Created by jpk on 4/28/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Image {

    @NSManaged var author: String?
    @NSManaged var id: String?
    @NSManaged var image: NSData?
    @NSManaged var over_18: NSNumber?
    @NSManaged var score: NSNumber?
    @NSManaged var subreddit: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var pageAfter: String?
    @NSManaged var imageURL: String?

}
