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
    
    static func parseJSON(jsonData: JSON) throws -> [MiteImage] {
        
        var returnMiteData: [MiteImage] = []
        
        guard let pageAfter = jsonData["data"]["after"].string else { throw ParsingError.FailedToParse(error: "Failed to parse pageAfter") }
        guard let jsonArray = jsonData["data"]["children"].array else { throw ParsingError.FailedToParse(error: "Failed to parse json children array") }
        
        for json in jsonArray {
            guard let author = json["data"]["author"].string else { throw ParsingError.FailedToParse(error: "Failed to parse author") }
            guard let id = json["data"]["id"].string else { throw ParsingError.FailedToParse(error: "Failed to parse id") }
            guard let over_18 = json["data"]["over_18"].bool else { throw ParsingError.FailedToParse(error: "Failed to parse over_18") }
            guard let score = json["data"]["score"].number  else { throw ParsingError.FailedToParse(error: "Failed to parse score") }
            guard let subreddit = json["data"]["subreddit"].string else { throw ParsingError.FailedToParse(error: "Failed to parse subreddit") }
            guard let title = json["data"]["title"].string else { throw ParsingError.FailedToParse(error: "Failed to parse title") }
            guard var url = json["data"]["url"].string else { throw ParsingError.FailedToParse(error: "Failed to parse url") }
            guard let mediaURL = self.modifyURL(url).filter({ $0.0 == "adjustedURL" }).map({ $0.1 as! String }).first else { throw ParsingError.FailedToParse(error: "Failed to parse media url") }
            guard let mediaBool = self.modifyURL(url).filter({ $0.0 == "media" }).map({ $0.1 as! Bool }).first else {
                throw ParsingError.FailedToParse(error: "Failed to parse media bool") }
            
            url = url == mediaURL ? url : mediaURL
            
            if let previews = json["data"]["preview"]["images"].array {
                for preview in previews {
                    guard let resolutions = preview["resolutions"].array else { throw ParsingError.FailedToParse(error: "Failed to parse resolutions") }
                    for resolution in resolutions {
                        if let width = resolution["width"].int where width == 320 {
                            guard let imageURL = resolution["url"].string else { throw ParsingError.FailedToParse(error: "Failed to parse imageURL") }
                            let modifiedURL = imageURL.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            returnMiteData.append(MiteImage(author: author, id: id, over_18: over_18, score: score, subreddit: subreddit, title: title, url: url, modifiedURL: modifiedURL, pageAfter: pageAfter, mediaBool: mediaBool))
                        }
                    }
                }
            }
        }
        return returnMiteData
    }
    
    private static func modifyURL(urlString: String) -> Dictionary<String, AnyObject> {
        var media: Bool = false
        let stringArray = urlString.componentsSeparatedByString(":")
        var adjustedURLString = String()
        
        if stringArray.first == "http" {
            adjustedURLString = "https:" + stringArray[1]
        }
        
        if adjustedURLString.hasSuffix("gifv") || adjustedURLString.hasSuffix("webm") {
            adjustedURLString = adjustedURLString.stringByReplacingOccurrencesOfString("gifv", withString: "mp4", options: .LiteralSearch, range: nil)
            media = true
        } else if adjustedURLString.hasSuffix("gif") {
            media = true
            return ["adjustedURL": adjustedURLString, "media": media]
        } else {
            return ["adjustedURL": urlString, "media": media]
        }
        
        return ["adjustedURL": adjustedURLString, "media": media]
    }
}
