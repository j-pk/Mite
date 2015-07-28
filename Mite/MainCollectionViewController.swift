//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation

let reuseIdentifier = "mainCell"
let redditAPI = "https://www.reddit.com/"

class MainCollectionViewController: UICollectionViewController, UIScrollViewDelegate, MainLayoutDelegate {
    
    var transitionManager = MenuTransitionManager()
    
    var redditImagesDictionary = [String:UIImage]()
    var redditImageIds = [String]()
    
    var searchRedditString = "r/art"
    
    var sourceIndexPath: NSIndexPath?
    
    var presenting = true
    
    ////////////////////MARK: Load
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        let titleBarImageView = UIImageView(frame: CGRectMake(0, 0, 54, 28))
        titleBarImageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        titleBarImageView.image = image
        navigationItem.titleView = titleBarImageView
        
        var sideMenuButton = UIButton()
        sideMenuButton.setImage(UIImage(named: "menu"), forState: .Normal)
        sideMenuButton.frame = CGRectMake(0, 0, 20, 16)
        sideMenuButton.contentMode = .ScaleAspectFit
        sideMenuButton.addTarget(self, action: "sideMenuButtonPressed:", forControlEvents: .TouchUpInside)
        
        var sideMenuBarItem = UIBarButtonItem()
        sideMenuBarItem.customView = sideMenuButton
        navigationItem.leftBarButtonItem = sideMenuBarItem
        
        var sideSubredditLabel = UILabel()
        sideSubredditLabel.frame = CGRectMake(0, 0, 100, 20)
        
        var sideSubredditBarItem = UIBarButtonItem()
        sideSubredditBarItem.customView = sideSubredditLabel
        navigationItem.rightBarButtonItem = sideSubredditBarItem
        
        sideSubredditLabel.textAlignment = .Right
        sideSubredditLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        sideSubredditLabel.text = ImageRequest.session().searchRedditString
        
        navigationController?.view.clipsToBounds = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        println(HTTPRequest.session().token)
        HTTPRequest.session().getUserIdentity { () -> Void in
            
            println("Identity")
            
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTheData:", name: "notifyToReload", object: nil)

        transitionManager.mainCollectionViewController = self
        
        let size = CGRectGetWidth(collectionView!.bounds) / 2
        
        let layout = collectionViewLayout as? MasterFlowLayout
        layout?.delegate = self
        layout?.numberOfColumns = 2
        layout?.cellPadding = 5
        layout?.width = CGRectGetWidth(collectionView!.bounds)
        layout?.insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView?.contentInset = layout!.insets
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressAction:")
        collectionView?.addGestureRecognizer(longPressGestureRecognizer)
        
        updateImages(false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ////////////////////MARK: CollectionView
    
    func reloadTheData(notification: NSNotification) {
                
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.updateImages(false)
            
        })
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return redditImageIds.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.upvoteButton.hidden = true
        cell.downvoteButton.hidden = true
        
        let key = redditImageIds[indexPath.row]
        
        cell.mainImageView.image = redditImagesDictionary[key]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let key = redditImageIds[indexPath.row]
        
        let photo = redditImagesDictionary[key]!
        
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRectWithAspectRatioInsideRect(photo.size, boundingRect)
        
        return rect.height
        
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        return 10
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    ////////////////////MARK: Manipulating Cell
    
    func longPressCellView(cell: MainCollectionViewCell, transform: CGAffineTransform, alpha: CGFloat) {
        
        cell.center = cell.center
        cell.transform = transform
        cell.alpha = alpha
        
    }
    
    ////////////////////MARK: Cell Gestures
    
    var pressStart: CGPoint?
    
    func longPressAction(gesture: UILongPressGestureRecognizer) {
        
        let location = gesture.locationInView(collectionView)
        let indexPath = collectionView!.indexPathForItemAtPoint(location)
        
        switch gesture.state {
            
        case .Began:
            
            pressStart = gesture.locationInView(collectionView)
            
            if let indexPath = indexPath {
                
                sourceIndexPath = indexPath
                if let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? MainCollectionViewCell {
                    
                    cell.upvoteButton.hidden = false
                    cell.downvoteButton.hidden = false
                    cell.layer.masksToBounds = false
                    cell.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
                    cell.layer.shadowRadius = 5.0
                    cell.layer.shadowOpacity = 0.4
                    
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        
                        self.longPressCellView(cell, transform: CGAffineTransformMakeScale(1.05, 1.05), alpha: 1.0)
                    })
                    
                    for c in collectionView!.visibleCells() as! [MainCollectionViewCell] {
                        
                        if c != cell {
                            
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                
                                c.alpha = 0.3
                                
                            })
                            
                        }
                        
                    }
                    
                }
                
            }
            
        case .Changed:
            
            let newPoint = gesture.locationInView(collectionView)
            let distanceY = pressStart!.y - newPoint.y
            if let sourceIndexPath = sourceIndexPath {
                
                if let cell = collectionView?.cellForItemAtIndexPath(sourceIndexPath) as? MainCollectionViewCell {
                    
                    if distanceY > 20 {
                        
                        let idName = redditImageIds[sourceIndexPath.row]
                        
                        // upvote
                        println("You're going up")
                        cell.pressingUp = true
                        cell.pressingDown = false

                    } else if distanceY < -20 {
                        
                        // downvote
                        println("You're going down")
                        cell.pressingDown = true
                        cell.pressingUp = false
                        
                    } else {
                        
                        // pan more
                        println("Keep going")
                        
                        
                    }
                    
                }
                
            }
        
        case .Ended:
            
            let newPoint = gesture.locationInView(collectionView)
            let distanceY = pressStart!.y - newPoint.y
            if let sourceIndexPath = sourceIndexPath {
                
                if let cell = collectionView?.cellForItemAtIndexPath(sourceIndexPath) as? MainCollectionViewCell {
                    
                    let idName = redditImageIds[sourceIndexPath.row]
                    
                    if distanceY > 20 {
                        
                        // upvote
                        println("You're going up")
                        cell.pressingUp = true
                        cell.pressingDown = false
                        
                        HTTPRequest.session().upvoteAndDownvote(idName, direction: 1, completion: { () -> Void in

                            println("upvote")
                            
                        })
                        
                    } else if distanceY < -20 {
                        
                        // downvote
                        println("You're going down")
                        cell.pressingDown = true
                        cell.pressingUp = false
                        
                        HTTPRequest.session().upvoteAndDownvote(idName, direction: -1, completion: { () -> Void in
                            
                            println("downvote")
                            
                        })
                        
                    } else {
                        
                        println("keep going")
                    }
                    
                    cell.upvoteButton.hidden = true
                    cell.downvoteButton.hidden = true
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        
                        self.longPressCellView(cell, transform: CGAffineTransformIdentity, alpha: 1.0)
                        cell.layer.masksToBounds = false
                        cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                        cell.layer.shadowRadius = 0.0
                        cell.layer.shadowOpacity = 0.0
                        
                        }, completion: { (finished) -> Void in
                            
                    })
                    
                    for c in collectionView!.visibleCells() as! [MainCollectionViewCell] {
                        
                        if c != cell {
                            
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                
                                c.alpha = 1
                                
                            })
                            
                        }
                        
                    }
                
                }
                
            }
            
        default:
            
            if let sourceIndexPath = sourceIndexPath {
                
                if let cell = collectionView?.cellForItemAtIndexPath(sourceIndexPath) as? MainCollectionViewCell {
                    
                }
                
            }
            
        }
        
    }
    
    // all ids including non images
    var redditIds = [String]()
    
    ////////////////////MARK: Update Images
    
    func updateImages(paginate: Bool) {
        
        var requestCount = 20
        var idArray: [String] = []
        
        searchRedditString = ImageRequest.session().searchRedditString
        
        var fullURL = "\(redditAPI)" + "\(searchRedditString)" + ".json"
        
        if paginate {
            
            fullURL += "?limit=\(requestCount)&after=\(ImageRequest.session().pageRedditAfter)"
            
        } else {
            
            redditImagesDictionary = [:]
            redditImageIds = []
            
            collectionView?.reloadData()
            collectionView?.contentOffset = CGPoint(x: 0, y: -70)
            
        }
        
        ImageRequest.session().jsonRequestForImages(fullURL, completion: { (images) -> () in
            
            self.hitBottom = false
            
            for (id,child) in images {
                
                println(self.redditIds)
                
                if contains(self.redditIds, id) { continue }
                
                self.redditIds.append(id)
                
                if var imageURL = child["url"] as? String {
                    
                    var ext = ""
                    
                    var urlParts = imageURL.componentsSeparatedByString(".")
                        
                    if urlParts.count > 1 {
                        
                        ext = urlParts.last!
                        
                        if urlParts.last == "gifv" {
                            
                            urlParts.removeLast()
                            urlParts.append("gif")
                            
                            imageURL = NSArray(array: urlParts).componentsJoinedByString(".")
                            
                            println(imageURL)
                            
                        }
                        
                    }
                    
                    if let url = NSURL(string: imageURL) {
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                            
                            if let imageData = NSData(contentsOfURL: url) {
                                
                                println("---------------------------------------------")
                                
                                switch ext {
                                    
                                case "gif", "gifv" :
                                    
                                    println("gifv")
                                    
                                    println("gif : " + imageURL)
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        
                                        if let image = UIImage.animatedGIF(imageData) {
                                    
                                            self.redditImagesDictionary[id] = image
                                            self.redditImageIds.append(id)
                                            
                                            self.collectionView?.reloadData()
                                            
                                        }
                                        
                                    })
                                    
                                    
                                default :
                                    
                                    let subData = imageData.subdataWithRange(NSMakeRange(0, 4))
                                    
                                    //println(subData.description)
                                    
                                    switch subData.description {
                                        
                                    case "<3c21444f>" :
                                        
                                        println("website")
                                        
                                        //changing url to not have http:// so it can search for image url in html
                                        let urlStripped = imageURL.stringByReplacingOccurrencesOfString("http://", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                                        
                                        let dataString = NSString(data: imageData, encoding: NSASCIIStringEncoding)
                                        
                                        //println(dataString)
                                        
                                        //spltting HTML at first occurence of the image url
                                        if let s1 = dataString?.componentsSeparatedByString("i.\(urlStripped).") {
                                            
                                            // if image found
                                            if s1.count > 1 {
                                                
                                                // finding extension
                                                if let s2 = (s1[1] as? String)?.componentsSeparatedByString("\"") {
                                                    
                                                    //println(s2[0])
                                                    
                                                    // if it is a jpg
                                                    if s2[0] == "jpg" {
                                                        
                                                        if let url = NSURL(string: "http://i.\(urlStripped).jpg") {
                                                            
                                                            if let imageData = NSData(contentsOfURL: url) {
                                                                
                                                                if let image = UIImage.animatedGIF(imageData) {
                                                                    
                                                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                                        
                                                                        self.redditImagesDictionary[id] = image
                                                                        self.redditImageIds.append(id)
                                                                        
                                                                        self.collectionView?.reloadData()
                                                                        
                                                                    })
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        
                                    case "<89504e47>" :
                                        
                                        println("png")
                                        
                                        if let image = UIImage.animatedGIF(imageData) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                
                                                self.redditImagesDictionary[id] = image
                                                self.redditImageIds.append(id)
                                                
                                                self.collectionView?.reloadData()
                                                
                                            })
                                            
                                        }
                                        
                                    default :
                                        
                                        println("jpg")
                                        
                                        if let image = UIImage.animatedGIF(imageData) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                
                                                self.redditImagesDictionary[id] = image
                                                self.redditImageIds.append(id)
                                                
                                                self.collectionView?.reloadData()
                                                
                                            })
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        })
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    ////////////////////MARK: Push & Exit VC
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "imageVC") {
            
            if let indexPath = collectionView!.indexPathsForSelectedItems().first as? NSIndexPath {
                
                if let imageVC = segue.destinationViewController as? ImageViewController {
                    
                    let key = redditImageIds[indexPath.row]

                    let child = ImageRequest.session().images[key]
                    
                    imageVC.detailTitle = child?["title"] as? String
                    
                    if let score = child?["score"] as? Int {
                        
                        imageVC.upvoteCount = String(score)
                        
                    }
                    
                    if let url = child?["url"] as? String {
                        
                        imageVC.imageURLToShare = url
                        
                    }
                    
                    if let id = child?["id"] as? String {
                        
                        imageVC.imageIDToVote = id
                    }
                    
                    imageVC.cell = sender as? MainCollectionViewCell
                    imageVC.detailImage = redditImagesDictionary[key]
                    imageVC.cellYOffset = -collectionView!.contentOffset.y
                }
                
            }
            
        }
        
        if (segue.identifier == "menuVC") {
            
            if let menuVC = segue.destinationViewController as? MenuViewController {
                
                menuVC.transitioningDelegate = transitionManager
                self.transitionManager.menuViewController = menuVC
                
            }
            
        }
        
    }
    
    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func sideMenuButtonPressed(sender: UIButton) {
        
        if presentedViewController != nil {
            presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            performSegueWithIdentifier("menuVC", sender: self)
        }
        
    }
    
    var hitBottom = false
    
    ////////////////////MARK: NavigationBar
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var previousScrollViewYOffset: CGFloat = 0.0
        
        var frame = self.navigationController?.navigationBar.frame
        var size = frame!.size.height - 21
        var framePercentageHidden = ((20 - frame!.origin.y) / (frame!.size.height - 1))
        var scrollOffset = scrollView.contentOffset.y
        var scrollDiff = scrollOffset - previousScrollViewYOffset
        var scrollHeight = scrollView.frame.size.height
        var scrollContentHeight = scrollView.contentSize.height
        var scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if scrollOffset <= -scrollView.contentInset.top {
            
            frame!.origin.y = 20
            
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            
            frame!.origin.y = -size
            
        } else {
            
            frame!.origin.y = min(20, max(-size, frame!.origin.y -
                (frame!.size.height * (scrollDiff / scrollHeight))))
            
        }
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            
            if hitBottom { return }
            
            println("You're at the bottom, request")
            
            hitBottom = true
            
            updateImages(true)
            
            // run request and in completion block ... hitBottom = false
            
        }
        
        self.navigationController?.navigationBar.frame = frame!
        updateBarButtonItems(1 - framePercentageHidden)
        previousScrollViewYOffset = scrollOffset
        
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        stoppedScrolling()
        
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if (!decelerate) {
            
            stoppedScrolling()
        }
        
    }
    
    func stoppedScrolling() {
        
        var frame = navigationController?.navigationBar.frame
        if frame?.origin.y < 20 {
            
            animateNavBarTo(-(frame!.size.height - 21))
        }
        
    }
    
    func updateBarButtonItems(alpha:CGFloat){
        if let left = navigationItem.leftBarButtonItems {
            for item:UIBarButtonItem in left as! [UIBarButtonItem] {
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }
        
        if let right = navigationItem.rightBarButtonItems {
            for item:UIBarButtonItem in  right as! [UIBarButtonItem]{
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }
        
        //hides title
        navigationItem.titleView?.alpha = alpha
        let black = UIColor.blackColor()
        let semi = black.colorWithAlphaComponent(alpha)
        var nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: semi]
        navigationController?.navigationBar.tintColor = navigationController?.navigationBar.tintColor.colorWithAlphaComponent(alpha)
    
    }
    
    func animateNavBarTo(y: CGFloat) {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            var frame = self.navigationController?.navigationBar.frame
            let alpha: CGFloat = (frame!.origin.y >= y ? 0 : 1)
            frame!.origin.y = y
            self.navigationController?.navigationBar.frame = frame!
            self.updateBarButtonItems(alpha)
            
        })
        
    }
    
}





