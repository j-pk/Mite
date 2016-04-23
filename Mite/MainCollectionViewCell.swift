//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    var pressingUp = false {
        didSet{
            pressingUp ? upvoteButton.setImage(UIImage(named: "upvoteSelected"), forState: .Normal) : upvoteButton.setImage(UIImage(named: "upvote"), forState: .Normal)
        }
    }
    
    var pressingDown = false {
        didSet {
            pressingDown ? downvoteButton.setImage(UIImage(named: "downvoteSelected"), forState: .Normal) : downvoteButton.setImage(UIImage(named: "downvote"), forState: .Normal)
        }
    }
    
    func configureCell(indexPath: NSIndexPath) {
        self.backgroundColor = UIColor.clearColor()
        self.upvoteButton.hidden = true
        self.downvoteButton.hidden = true
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let data = ImageRequest.session().redditData[indexPath.row]
            let photo = data.image
            self.mainImageView.image = photo
        })
    }
    
    func longPressCellView(transform: CGAffineTransform, alpha: CGFloat) {
        self.center = self.center
        self.transform = transform
        self.alpha = alpha
    }
    
    func reduceCellAlpha(collectionView: UICollectionView) {
        for c in collectionView.visibleCells() as! [MainCollectionViewCell] {
            if c != self {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    c.alpha = 0.3
                })
            }
        }
    }
    
    func configureGestureOnCell(gesture: UILongPressGestureRecognizer, gestureLocation: CGPoint, indexPath: NSIndexPath,collectionView: UICollectionView?) {
        
        let id = ImageRequest.session().redditData[indexPath.row]
        let idName = id.id
        let pressStart: CGFloat?
        
        switch gesture.state {
            
        case .Began:
            pressStart = gestureLocation.y
            print(pressStart)
            
            self.upvoteButton.hidden = false
            self.downvoteButton.hidden = false
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
            self.layer.shadowRadius = 5.0
            self.layer.shadowOpacity = 0.4
            
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                self.longPressCellView(CGAffineTransformMakeScale(1.05, 1.05), alpha: 1.0)
            })
            
        case .Changed:
            pressStart = gestureLocation.y
            let distanceY = gestureLocation.y - pressStart!
            print(distanceY)
            
            if distanceY > 20 {
                // upvote
                print("You're going up")
                self.pressingUp = true
                self.pressingDown = false
                
            } else if distanceY < -20 {
                // downvote
                print("You're going down")
                self.pressingDown = true
                self.pressingUp = false
            } else {
                // pan more
                print("Keep going")
            }
            
            
        case .Ended:
            pressStart = gestureLocation.y
            let distanceY = gestureLocation.y - pressStart!
            
            if distanceY > 20 {
                // upvote
                print("You're going up")
                HTTPRequest.session().upvoteAndDownvote(idName, direction: 1, completion: { () -> Void in
                    print("upvote")
                })
                
            } else if distanceY < -20 {
                // downvote
                print("You're going down")
                HTTPRequest.session().upvoteAndDownvote(idName, direction: -1, completion: { () -> Void in
                    print("downvote")
                })
                
            } else {
                print("keep going")
            }
            
            self.upvoteButton.hidden = true
            self.downvoteButton.hidden = true
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.longPressCellView(CGAffineTransformIdentity, alpha: 1.0)
                self.layer.masksToBounds = false
                self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                self.layer.shadowRadius = 0.0
                self.layer.shadowOpacity = 0.0
                
                }, completion: { (finished) -> Void in
                    
            })
            //self.reduceCellAlpha(collectionView)
        default:
            break
            
        }
    }
}
