//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation

let reuseIdentifier = "mainCell"
let redditAPI = "https://www.reddit.com/"

class MainCollectionViewController: UICollectionViewController, MainLayoutDelegate {
    
    var transitionManager = MenuTransitionManager()
    
    var searchRedditString = "r/art"
    
    var sourceIndexPath: NSIndexPath?
    
    var presenting = true
    var hitBottom = false
    
    ////////////////////MARK: Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.updateImages(false)
        
        transitionManager.mainCollectionViewController = self
        self.configureViews()
        self.configureCollectionView()
        
        print(NetworkManager.sharedInstance.token)
        NetworkManager.sharedInstance.getUserIdentity()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reloadTheData), name: "notifyToReload", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.sendLoginAlert), name: "sendAlert", object: nil)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
        collectionView?.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    ////////////////////MARK: Configure Views
    
    func configureViews() {
        let titleBarImageView = UIImageView(frame: CGRectMake(0, 0, 54, 28))
        titleBarImageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        titleBarImageView.image = image
        navigationItem.titleView = titleBarImageView
        
        let sideMenuButton = UIButton()
        sideMenuButton.setImage(UIImage(named: "menu"), forState: .Normal)
        sideMenuButton.frame = CGRectMake(0, 0, 20, 16)
        sideMenuButton.contentMode = .ScaleAspectFit
        sideMenuButton.addTarget(self, action: #selector(self.sideMenuButtonPressed), forControlEvents: .TouchUpInside)
        
        let sideMenuBarItem = UIBarButtonItem()
        sideMenuBarItem.customView = sideMenuButton
        navigationItem.leftBarButtonItem = sideMenuBarItem
        
        let sideSubredditLabel = UILabel()
        sideSubredditLabel.frame = CGRectMake(0, 0, 100, 20)
        
        let sideSubredditBarItem = UIBarButtonItem()
        sideSubredditBarItem.customView = sideSubredditLabel
        navigationItem.rightBarButtonItem = sideSubredditBarItem
        
        sideSubredditLabel.textAlignment = .Right
        sideSubredditLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        sideSubredditLabel.text = NetworkManager.sharedInstance.searchRedditString
        
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBarHidden = false
        navigationController?.view.clipsToBounds = true
        
        self.collectionView?.reloadData()
    }
    
    func configureCollectionView() {
        let layout = collectionViewLayout as? MasterFlowLayout
        layout?.delegate = self
        layout?.numberOfColumns = 2
        layout?.cellPadding = 5
        layout?.width = CGRectGetWidth(collectionView!.bounds)
        layout?.insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView?.contentInset = layout!.insets
    }
    
    ////////////////////MARK: CollectionView
    
    func reloadTheData(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateImages(false)
            NetworkManager.sharedInstance.redditData = []
            self.collectionView?.reloadData()
        })
    }
    
    func sendLoginAlert(notification: NSNotification) {
        Alert.session().successfulLoginAlert()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NetworkManager.sharedInstance.redditData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
        
        cell.configureCell(indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let data = NetworkManager.sharedInstance.redditData[indexPath.row]
        let photo = data.image
        
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRectWithAspectRatioInsideRect(photo.size, boundingRect)
        
        return rect.height
        
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        return 0
    }

    ////////////////////MARK: Cell Gestures
        
    func longPressAction(gesture: UILongPressGestureRecognizer) {
        
        let location = gesture.locationInView(collectionView)
        guard let indexPath = collectionView?.indexPathForItemAtPoint(location),
              let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? MainCollectionViewCell else { return }
        
        cell.configureGestureOnCell(gesture, gestureLocation: location, indexPath: indexPath, collectionView: collectionView)
        
    }
    
    ////////////////////MARK: Update Images
    
    func updateImages(paginate: Bool) {
        
        let requestCount = 10
        searchRedditString = NetworkManager.sharedInstance.searchRedditString
        var fullURL = "\(redditAPI)" + "\(searchRedditString)" + ".json"
        print(fullURL)
        if paginate {
            fullURL += "?limit=\(requestCount)&after=\(NetworkManager.sharedInstance.pageRedditAfter)"
        } else {
            collectionView?.reloadData()
            collectionView?.contentOffset = CGPoint(x: 0, y: -70)
        }
        
        NetworkManager.sharedInstance.requestImages(fullURL, completion: { (images) -> () in
            self.hitBottom = false
            self.collectionView?.reloadData()
        })
    }
    
    ////////////////////MARK: Push & Exit VC
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "imageVC") {
            
            if let indexPath = collectionView!.indexPathsForSelectedItems()!.first {
                
                if let imageVC = segue.destinationViewController as? ImageViewController {
                    
                    let data = NetworkManager.sharedInstance.redditData[indexPath.row]
                    let image = data.image
                    let scoreToSend = NetworkManager.sharedInstance.redditData[indexPath.row]
                    let score = scoreToSend.score
                    let idToSend = NetworkManager.sharedInstance.redditData[indexPath.row]
                    let id = idToSend.id
                    let titleToSend = NetworkManager.sharedInstance.redditData[indexPath.row]
                    let title = titleToSend.title
                    let urlToSend = NetworkManager.sharedInstance.redditData[indexPath.row]
                    let url = urlToSend.url
                    
                    imageVC.upvoteCount = String(score)
                    imageVC.detailImage = image
                    imageVC.detailTitle = title 
                    imageVC.imageURLToShare = url
                    imageVC.imageIDToVote = id

                    imageVC.cell = sender as? MainCollectionViewCell
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
    
}

extension MainCollectionViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var previousScrollViewYOffset: CGFloat = 0.0
        
        var frame = self.navigationController?.navigationBar.frame
        let size = frame!.size.height - 21
        let framePercentageHidden = ((20 - frame!.origin.y) / (frame!.size.height - 1))
        let scrollOffset = scrollView.contentOffset.y
        let scrollDiff = scrollOffset - previousScrollViewYOffset
        let scrollHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if scrollOffset <= -scrollView.contentInset.top {
            
            frame!.origin.y = 20
            
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            
            frame!.origin.y = -size
            
        } else {
            
            frame!.origin.y = min(20, max(-size, frame!.origin.y -
                (frame!.size.height * (scrollDiff / scrollHeight))))
            
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
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            
            if hitBottom { return }
            print("You're at the bottom, request")
            hitBottom = true
            updateImages(true)
            // run request and in completion block ... hitBottom = false
            
        }
    }
    
    func stoppedScrolling() {
        let frame = navigationController?.navigationBar.frame
        if frame?.origin.y < 20 {
            
            animateNavBarTo(-(frame!.size.height - 21))
        }
        
    }
    
    func updateBarButtonItems(alpha:CGFloat){
        if let left = navigationItem.leftBarButtonItems {
            for item:UIBarButtonItem in left {
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }
        
        if let right = navigationItem.rightBarButtonItems {
            for item:UIBarButtonItem in  right {
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }
        
        //hides title
        navigationItem.titleView?.alpha = alpha
        let black = UIColor.blackColor()
        let semi = black.colorWithAlphaComponent(alpha)
        let nav = self.navigationController?.navigationBar
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







