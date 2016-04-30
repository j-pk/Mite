//
//  ImageCacheManager.swift
//  Mite
//
//  Created by Jameson Kirby on 4/29/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import UIKit

class ImageCacheManager {
    
    static let sharedInstance = ImageCacheManager()
    
    var imageCache = NSCache()
    
    func addImageToCache(image:UIImage, withKey key:String) {
        self.imageCache.setObject(image, forKey: key)
    }
    
    func fetchImage(withKey key:String) -> UIImage? {
        return self.imageCache.objectForKey(key) as? UIImage
    }
    
}