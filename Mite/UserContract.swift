//
//  UserContract.swift
//  Mite
//
//  Created by jpk on 5/22/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UserContract {
    static func parseJSON(jsonData: JSON) throws -> User {
        guard let isGold = jsonData["is_gold"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse isGold") }
        guard let over_18 = jsonData["over_18"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse over_18") }
        guard let name = jsonData["name"].string else { throw ParsingError.FailedToParse(error: "Failed to parse name") }
        guard let hasVerifiedEmail = jsonData["has_verified_email"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse email") }
        guard let linkKarma = jsonData["link_karma"].int else { throw ParsingError.FailedToParse(error: "Failed to parse linkKarma") }
        guard let isMod = jsonData["is_mod"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse isMod") }
        guard let created = jsonData["created_utc"].double else { throw ParsingError.FailedToParse(error: "Failed to parse created") }
        let date = NSDate(timeIntervalSince1970: created)
        return User(isGold: isGold, over_18: over_18, name: name, hasVerifiedEmail: hasVerifiedEmail, linkKarma: linkKarma, isMod: isMod, created: date)
    }
}
