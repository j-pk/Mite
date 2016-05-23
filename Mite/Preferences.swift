//
//  Preferences.swift
//  Mite
//
//  Created by jpk on 5/22/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation


struct Preferences {
    var label_nsfw: Bool
    var over_18: Bool
    
    init(label_nsfw: Bool, over_18: Bool) {
        self.label_nsfw = label_nsfw
        self.over_18 = over_18
    }
}