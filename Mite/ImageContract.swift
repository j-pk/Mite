//
//  ImageContract.swift
//  Mite
//
//  Created by jpk on 4/27/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ParsingError: ErrorType {
    case FailedToParse(error: String)
}

extension JSON {
    public init(_ jsonArray:[JSON]) {
        self.init(jsonArray.map { $0.object })
    }
}

struct ImageContract {
    
    static func parseJSON(jsonData: JSON) throws -> [Dictionary<String, AnyObject>] {
        
        var returnDictionary: [Dictionary<String, AnyObject>] = [[:]]
        
        guard let pageAfter = jsonData["data"]["after"].string else { throw ParsingError.FailedToParse(error: "Failed to parse pageAfter") }
        guard let jsonArray = jsonData["data"]["children"].array else { throw ParsingError.FailedToParse(error: "Failed to parse json children array") }
        
        for json in jsonArray {
            guard let author = json["data"]["author"].string else { throw ParsingError.FailedToParse(error: "Failed to parse author") }
            guard let id = json["data"]["id"].string else { throw ParsingError.FailedToParse(error: "Failed to parse id") }
            guard let over_18 = json["data"]["over_18"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse over_18") }
            guard let score = json["data"]["score"].number  else { throw ParsingError.FailedToParse(error: "Failed to parse score") }
            guard let subreddit = json["data"]["subreddit"].string else { throw ParsingError.FailedToParse(error: "Failed to parse subreddit") }
            guard let title = json["data"]["title"].string else { throw ParsingError.FailedToParse(error: "Failed to parse title") }
            guard let url = json["data"]["url"].string else { throw ParsingError.FailedToParse(error: "Failed to parse url") }
            
            returnDictionary.append(["author": author, "id": id, "over_18": over_18, "score": score, "subreddit": subreddit, "title": title, "url": url, "pageAfter": pageAfter])
            if let previews = json["data"]["preview"]["images"].array {
                for preview in previews {
                    guard let resolutions = preview["resolutions"].array else { throw ParsingError.FailedToParse(error: "Failed to parse resolutions") }
                    for resolution in resolutions {
                        if let width = resolution["width"].int where width == 320 {
                            guard let imageURL = resolution["url"].string else { throw ParsingError.FailedToParse(error: "Failed to parse imageURL") }
                            let modifiedURL = imageURL.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            returnDictionary.append(["imageURL": modifiedURL])
                        }
                    }
                }
            }
        }
        return returnDictionary
    }
}
