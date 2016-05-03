//
//  MiteViewController.swift
//  Mite
//
//  Created by Jameson Kirby on 4/30/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit

class MiteViewController: UIViewController {

    @IBOutlet weak var miteCollectionView: UICollectionView!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var subredditLabel: UILabel!
    
    var miteImages = [MiteImages]()
    private var transitionManager = MenuTransitionManager()
    private var hitBottom = false
    private var initialGestureState: CGPoint?
    private var defaultSubreddit: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAPIData(paginate: false)
        self.setupCollectionView()
        self.setupViews()
        
        self.transitionManager.viewController = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressOnCell))
        miteCollectionView?.addGestureRecognizer(longPressGestureRecognizer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reloadData), name: "notifyToReload", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.sendLoginAlert), name: "sendAlert", object: nil)
    }
    
    func setupCollectionView(){
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        layout.columnCount = 2
        layout.headerHeight = 10
        layout.footerHeight = 10
        layout.sectionInset = UIEdgeInsets(top: 44, left: 10, bottom: 0, right: 10)
        
        // Collection view attributes
        self.miteCollectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.miteCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.miteCollectionView.collectionViewLayout = layout
    }
    
    //MARK: Configure Views
    func setupViews() {
        self.navBarView.layer.shadowColor = UIColor.blackColor().CGColor
        self.navBarView.layer.shadowOpacity = 0.20
        self.navBarView.layer.shadowOffset = CGSizeMake(0, 2.0)
        self.navBarView.layer.shadowRadius = 2.0
        self.miteCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0)
        self.defaultSubreddit = "r/top"
        self.subredditLabel.text = self.defaultSubreddit
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        if presentedViewController != nil {
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.performSegueWithIdentifier("menuVC", sender: self)
        }
    }
    
    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchAPIData(paginate paginate: Bool) {
        let requestCount = 15
        var fullURL = redditAPI + NetworkManager.sharedInstance.searchRedditString + ".json"
        self.subredditLabel.text = self.defaultSubreddit ?? NetworkManager.sharedInstance.searchRedditString
        
        if paginate {
            if let pageAfter = self.miteImages.last!["pageAfter"] as? String {
                fullURL += "?limit=\(requestCount)&after=\(pageAfter)"
            }
        }
        
        NetworkManager.sharedInstance.requestImages(fullURL) { (data) in
            if !paginate {
                self.miteImages = data
            } else {
                data.forEach({ self.miteImages.append($0) })
            }
            for image in self.miteImages {
                if let imageURL = image["imageURL"] as? String {
                    NetworkManager.sharedInstance.fetchImage(fromUrl: imageURL) { (image) in
                        self.miteCollectionView.reloadData()
                    }
                }
            }
            self.hitBottom = false
        }
    }
    
    func reloadData(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.miteImages = []
            ImageCacheManager.sharedInstance.imageCache.removeAllObjects()
            self.defaultSubreddit = nil
            self.fetchAPIData(paginate: false)
        })
    }
    
    func sendLoginAlert(notification: NSNotification) {
        Alert.session().successfulLoginAlert()
    }
    
    func setAlphaStateForDeselectedCells(cell: MiteCollectionViewCell, alpha: CGFloat) {
        for c in miteCollectionView!.visibleCells() as! [MiteCollectionViewCell] {
            if c != cell {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    c.alpha = alpha
                })
            }
        }
    }
    
    func longPressOnCell(gesture: UILongPressGestureRecognizer) {
        let location = gesture.locationInView(self.miteCollectionView)
        let indexPath = self.miteCollectionView!.indexPathForItemAtPoint(location)
        guard let index = indexPath, cell = miteCollectionView!.cellForItemAtIndexPath(index) as? MiteCollectionViewCell else { return }
        
        switch gesture.state {
        case .Began:
            self.initialGestureState = gesture.locationInView(miteCollectionView)
            cell.initialGestureState()
            self.setAlphaStateForDeselectedCells(cell, alpha: 0.2)
        
        case .Changed:
            guard let initialGestureState = self.initialGestureState else { return }
            let distanceY = initialGestureState.y - location.y
            cell.cellVote(distanceY)
        case .Ended:
            guard let initialGestureState = self.initialGestureState else { return }
            let distanceY = initialGestureState.y - location.y
            let indexPath = self.miteCollectionView!.indexPathForItemAtPoint(initialGestureState)
            let newPoint = gesture.locationInView(self.miteCollectionView)
            let newIndexPath = self.miteCollectionView!.indexPathForItemAtPoint(newPoint)
            
            cell.cellVote(distanceY)
            cell.resetCell()
            self.setAlphaStateForDeselectedCells(cell, alpha: 1.0)
            if newIndexPath != indexPath {
                if let cell = miteCollectionView!.cellForItemAtIndexPath(indexPath!) as? MiteCollectionViewCell {
                    cell.resetCell()
                }
            }
        default:
            cell.resetCell()
        }
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "imageVC") {
            if let indexPath = self.miteCollectionView!.indexPathsForSelectedItems()!.first {
                if let imageVC = segue.destinationViewController as? ImageViewController {
                    
                    let image = self.miteImages[indexPath.row]["imageURL"] as? String
                    let score = self.miteImages[indexPath.row]["score"] as? Int
                    let id = self.miteImages[indexPath.row]["id"] as? String
                    let title = self.miteImages[indexPath.row]["title"] as? String
                    let url = self.miteImages[indexPath.row]["url"] as? String
                    let media = self.miteImages[indexPath.row]["media"] as! Bool
                    
                    if let score = score {
                        imageVC.upvoteCount = String(score)
                    }
                    imageVC.imageURL = image
                    imageVC.detailTitle = title
                    imageVC.imageURLToShare = url
                    imageVC.imageIDToVote = id
                    imageVC.media = media 
                    
                    imageVC.cell = sender as? MiteCollectionViewCell
                    imageVC.cellYOffset = -self.miteCollectionView!.contentOffset.y
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

}

extension MiteViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.miteImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MiteCollectionViewCell

        cell.configureCell(self.miteImages[indexPath.row])
        
        return cell
    }
}

extension MiteViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
        guard let imageURL = self.miteImages[indexPath.row]["imageURL"] as? String else { return CGSizeZero }
        guard let image = ImageCacheManager.sharedInstance.fetchImage(withKey: imageURL) else { return CGSizeZero }

        return image.size
    }
}

extension MiteViewController {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if self.hitBottom { return }
            self.hitBottom = true
            self.fetchAPIData(paginate: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocityInView(scrollView).y
        if velocity < 0 {
            UIView.animateWithDuration(0.5, animations: {
                self.navBarView.alpha = 0.8
            })
        } else if velocity > 0 {
            UIView.animateWithDuration(0.5, animations: {
                self.navBarView.alpha = 1.0
            })
        }
    }
}
