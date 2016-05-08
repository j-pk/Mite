//
//  Dictionary+Combine.swift
//  Mite
//
//  Created by jpk on 5/4/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}