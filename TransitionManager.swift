//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

class MenuTransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    private var presenting = false
    private var interactive = false
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    var mainViewCollection: UIViewController?
    
    //Transition to Menu
    var mainCollectionViewController: UIViewController! {
        
        didSet {
            
            enterPanGesture = UIScreenEdgePanGestureRecognizer()
            enterPanGesture.addTarget(self, action: #selector(self.handleOnstagePan))
            enterPanGesture.edges = UIRectEdge.Left
            self.mainCollectionViewController.view.addGestureRecognizer(enterPanGesture)

        }
        
    }
    
    func handleOnstagePan(gesture: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gesture.translationInView(gesture.view!)
        let percentageOfScreen = translation.x / CGRectGetWidth(gesture.view!.bounds) * 0.5
        
        switch gesture.state {
            
        case UIGestureRecognizerState.Began:
            
            self.interactive = true
            self.mainCollectionViewController.performSegueWithIdentifier("menuVC", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            
            self.updateInteractiveTransition(percentageOfScreen)
            break
            
        default:
            
            self.interactive = false
            if percentageOfScreen > 0.2 {
                
                self.finishInteractiveTransition()
                
            } else {
                
                self.cancelInteractiveTransition()
            }
            
        }
        
    }
    
    //Transition to Dismiss Menu
    private var exitPanGesture: UIPanGestureRecognizer!

    var menuViewController: UIViewController! {
        
        didSet {
            exitPanGesture = UIPanGestureRecognizer()
            exitPanGesture.addTarget(self, action: #selector(self.handleOffstagePan))
            self.menuViewController.view.addGestureRecognizer(exitPanGesture)
        }
        
    }

    func handleOffstagePan(exitGesture: UIPanGestureRecognizer) {
        
        let translation = exitGesture.translationInView(exitGesture.view!)
        let percentageOfScreen = translation.x / CGRectGetWidth(exitGesture.view!.bounds) * -0.5
        
        switch exitGesture.state {
            
        case UIGestureRecognizerState.Began:
            
            self.interactive = true
            self.menuViewController.performSegueWithIdentifier("dismissMenu", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            
            self.updateInteractiveTransition(percentageOfScreen)
            break
            
        default:
            
            self.interactive = false
   
            if percentageOfScreen > 0.1 {
                self.finishInteractiveTransition()
            }
            else {
                self.cancelInteractiveTransition()
            }
            
        }
        
    }
    
    // animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView()
     
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        let menuViewController = !self.presenting ? screens.from as! MenuViewController : screens.to as! MenuViewController
        let mainViewCollection = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let menuView = menuViewController.view
        let mainView = mainViewCollection.view
        
        mainView.layer.masksToBounds = false
        mainView.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        mainView.layer.shadowRadius = 5.0
        mainView.layer.shadowOpacity = 0.4
        
        if presenting {
            
            offStageMenuControllerInteractive(menuViewController)
            
        }
        
        container?.addSubview(menuView)
        container?.addSubview(mainView)
        
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            
            if self.presenting {
                self.onStageMenuController(menuViewController) // onstage items: slide in
               
                let mainRemains = mainView.frame.width / 1.10
                let shiftRightOffset = CGAffineTransformMakeTranslation(mainRemains, 0)
                let shiftAndShrink = CGAffineTransformMakeScale(0.75, 0.75)
                mainView.transform = CGAffineTransformConcat(shiftRightOffset, shiftAndShrink)
                
            } else {
                mainView.transform = CGAffineTransformIdentity
                self.offStageMenuControllerInteractive(menuViewController)
            }
            
        }, completion: { finished in
  
            if !transitionContext.transitionWasCancelled() {
                
                let newView = self.presenting ? screens.from.view : screens.to.view
                let oldView = self.presenting ? screens.to.view : screens.from.view
                
                transitionContext.completeTransition(true)
                UIApplication.sharedApplication().keyWindow!.insertSubview(newView, aboveSubview: oldView)

                // TODO: target further in to only disable collectionview
                newView.userInteractionEnabled = !self.presenting
                
                for view in newView.subviews {
                    print(view)
                }
                
            } else {
                
                self.mainViewCollection = mainViewCollection
                transitionContext.completeTransition(false)

            }
                
        })
        
    }
    
    ////////////////////MARK: Transition for Menu Items
    
    func offStage(amount: CGFloat) -> CGAffineTransform {
        
        return CGAffineTransformMakeTranslation(amount, 0)
        
    }
    
    func offStageMenuControllerInteractive(menuViewController: MenuViewController) {
        
        menuViewController.view.alpha = 0
        
        let offstageOffset: CGFloat = 50
        let shiftLeftOffset = CGAffineTransformMakeTranslation(offstageOffset, 0)
        let shiftAndShrink = CGAffineTransformMakeScale(0.8, 0.8)
        
        menuViewController.subredditSearch.alpha = 0
        menuViewController.popularSubredditsLabel.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.picsButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.awwButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.funnyButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.iTookAPictureButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.artButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.loginButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.cancelButton.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.userNameLabel.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)
        menuViewController.customizeLabel.transform = CGAffineTransformConcat(shiftLeftOffset, shiftAndShrink)

    }
    
    func onStageMenuController(menuViewController: MenuViewController) {
        
        menuViewController.view.alpha = 1
        
        menuViewController.subredditSearch.alpha = 1
        menuViewController.popularSubredditsLabel.transform = CGAffineTransformIdentity
        menuViewController.picsButton.transform = CGAffineTransformIdentity
        menuViewController.awwButton.transform = CGAffineTransformIdentity
        menuViewController.funnyButton.transform = CGAffineTransformIdentity
        menuViewController.iTookAPictureButton.transform = CGAffineTransformIdentity
        menuViewController.artButton.transform = CGAffineTransformIdentity
        menuViewController.loginButton.transform = CGAffineTransformIdentity
        menuViewController.cancelButton.transform = CGAffineTransformIdentity
        menuViewController.userNameLabel.transform = CGAffineTransformIdentity
        menuViewController.customizeLabel.transform = CGAffineTransformIdentity
        
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return 0.5
    }
    
    func animationEnded(transitionCompleted: Bool) {
                
        if transitionCompleted == false {
            
            UIApplication.sharedApplication().keyWindow!.addSubview(mainViewCollection!.view)

        }
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if interactive flag is true, return the transition manager object
        // otherwise return nil
        
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactive ? self : nil
    }
}