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
     
}
