//
//  MiteImage.swift
//  Mite
//
//  Created by jpk on 5/5/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit

struct MiteImage {
    var author: String
    var id: String
    var over_18: Bool
    var score: NSNumber
    var subreddit: String
    var title: String
    var url: String
    var modifiedURL: String
    var pageAfter: String
    var mediaBool: Bool
    var image: UIImage?
    
    init(author: String, id: String, over_18: Bool, score: NSNumber, subreddit: String, title: String, url: String, modifiedURL: String, pageAfter: String, mediaBool: Bool) {
        self.author = author
        self.id = id
        self.over_18 = over_18
        self.score = score
        self.subreddit = subreddit
        self.title = title
        self.url = url
        self.modifiedURL = modifiedURL
        self.pageAfter = pageAfter
        self.mediaBool = mediaBool
    }
}