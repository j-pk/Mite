//
//  ImageCacheManager.swift
//  Mite
//
//  Created by Jameson Kirby on 4/29/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class ImageCacheManager {
    
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
    )
    
    static let sharedInstance = ImageCacheManager()
    
    func addImageToCache(image:UIImage, withKey key:String) {
        self.imageCache.addImage(image, withIdentifier: key)
    }
    
    func fetchImage(withKey key:String) -> UIImage? {
        return self.imageCache.imageWithIdentifier(key)
    }
    
}