//
//  User.swift
//  Mite
//
//  Created by jpk on 5/22/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation

struct User {
    var isGold: Bool
    var over_18: Bool
    var name: String
    var hasVerifiedEmail: Bool
    var linkKarma: Int
    var isMod: Bool
    var created: NSDate
    
    init(isGold: Bool, over_18: Bool, name: String, hasVerifiedEmail: Bool, linkKarma: Int, isMod: Bool, created: NSDate) {
        self.isGold = isGold
        self.over_18 = over_18
        self.name = name
        self.hasVerifiedEmail = hasVerifiedEmail
        self.linkKarma = linkKarma
        self.isMod = isMod
        self.created = created
    }
}