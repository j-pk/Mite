//
//  PreferencesContract.swift
//  Mite
//
//  Created by jpk on 5/22/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PreferencesContract {
    static func parseJSON(jsonData: JSON) throws -> Preferences {
        guard let over_18 = jsonData["over_18"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse over_18") }
        guard let label_nsfw = jsonData["label_nsfw"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse label_nsfw") }
        return Preferences(label_nsfw: label_nsfw, over_18: over_18)
    }
}