//
//  MiteViewController.swift
//  Mite
//
//  Created by Jameson Kirby on 4/30/16.
//  Copyright © 2016 Parker Kirby. All rights reserved.
//

import UIKit
import Alamofire

class MiteViewController: UIViewController, VoteStateForImageDelegate {

    @IBOutlet weak var miteCollectionView: UICollectionView!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var activityIndicator: CircularProgressView!

    private var transitionManager = MenuTransitionManager()
    private var hitBottom = false
    private var initialGestureState: CGPoint?
    private var defaultSubreddit: String?
    private var miteImages = [MiteImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(Router.GetIdentity).responseJSON { response in
            print(response.response?.allHeaderFields)
            print(response.result.value)
            print(response.request)
        }
        print(NetworkManager.sharedInstance.token)
        self.fetchAPIData(paginate: false)
        self.setupCollectionView()
        self.setupViews()
        self.transitionManager.viewController = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressOnCell))
        miteCollectionView?.addGestureRecognizer(longPressGestureRecognizer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reloadData), name: "notifyToReload", object: nil)
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
        
        if paginate {
            if let pageAfter = self.miteImages.last?.pageAfter {
                fullURL += "?limit=\(requestCount)&after=\(pageAfter)"
            }
        }
        
        activityIndicator.hidden = false
        let blockOperation = NSBlockOperation {
            NetworkManager.sharedInstance.requestImages(fullURL) { (data) in
                if !paginate {
                    self.miteImages = data
                } else {
                    data.forEach({ self.miteImages.append($0) })
                }
                data.forEach({ mite in
                    NetworkManager.sharedInstance.fetchImage(fromUrl: mite.modifiedURL) { _ in
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.activityIndicator.hidden = true
                            self.miteCollectionView.reloadData()
                        }
                    }
                })
            }
        }
        let queue = NSOperationQueue()
        queue.addOperation(blockOperation)
    }
    
    func reloadData(notification: NSNotification) {
        self.miteImages = []
        self.defaultSubreddit = nil
        self.subredditLabel.text = NetworkManager.sharedInstance.searchRedditString
        self.fetchAPIData(paginate: false)
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
                    imageVC.upvoteCount = String(self.miteImages[indexPath.row].score)
                    imageVC.imageURL = self.miteImages[indexPath.row].modifiedURL
                    imageVC.detailTitle = self.miteImages[indexPath.row].title
                    imageVC.imageURLToShare = self.miteImages[indexPath.row].url
                    imageVC.imageIDToVote = self.miteImages[indexPath.row].id
                    imageVC.media = self.miteImages[indexPath.row].mediaBool
                    imageVC.buttonState = self.miteImages[indexPath.row].buttonState
                    imageVC.cell = sender as? MiteCollectionViewCell
                    imageVC.cellYOffset = -self.miteCollectionView!.contentOffset.y
                    imageVC.delegate = self 
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
    
    func voteState(id: String, state: Bool) {
        for (index, data) in self.miteImages.enumerate() where data.id == id {
            self.miteImages[index].buttonState = state
        }
    }

}

extension MiteViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.miteImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mainCell", forIndexPath: indexPath) as! MiteCollectionViewCell

        cell.configureCell(self.miteImages[indexPath.row])
        
        return cell
    }
}

extension MiteViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
        guard let image = ImageCacheManager.sharedInstance.fetchImage(withKey: self.miteImages[indexPath.row].modifiedURL) else { return CGSizeZero }

        return image.size
    }
}

extension MiteViewController {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
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
