//
//import UIKit
//import ImageIO
//
//extension UIImage {
//    class func animatedGIF(data: NSData) -> UIImage? {
//        let source: CGImageSourceRef = CGImageSourceCreateWithData(data, nil)!
//        let count: Int = CGImageSourceGetCount(source)
//        
//        if (count < 2) {
//            
//            // Return non-animating image
//            return UIImage(data: data)
//        }
//        
//        // Compile array of key frames
//        var frames: Array<(CGImageRef, Float)> = []
//        for (var i: Int = 0; i < count; ++i) {
//            
//            // Mimic WebKit approach to determine frame duration
//            var delay: Float = 0.1 // WebKit default duration
//            if let frameProperties: NSDictionary = CGImageSourceCopyPropertiesAtIndex(source, i, nil), GIFProperties = frameProperties["{GIF}"] as? Dictionary<String, AnyObject> {
//                if let unclampedDelayTime = GIFProperties["UnclampedDelayTime"] as? Float {
//                    
//                    // Prefer "unclamped" delay time
//                    delay = unclampedDelayTime
//                } else if let delayTime = GIFProperties["DelayTime"] as? Float {
//                    delay = delayTime
//                }
//            }
//            let frame: (CGImageRef, Float) = (CGImageSourceCreateImageAtIndex(source, i, nil)!, delay)
//            frames.append(frame)
//        }
//        
//        // Convert key frames to animated image
//        var images: Array<AnyObject> = []
//        var duration: Float = 0
//        for frame in frames {
//            if let image = UIImage(CGImage: frame.0) {
//                let framesCount = UInt(frame.1 * 100.0)
//                for (var i: UInt = 0; i < framesCount; i++) {
//                    images.append(image)
//                }
//                duration += frame.1
//            }
//        }
//        return UIImage.animatedImageWithImages(images, duration: NSTimeInterval(duration))
//    }
//}