//
//  CircularProgressView.swift
//  Mite
//
//  Created by Jameson Kirby on 1/15/16.
//  Copyright © 2016 Jameson Kirby. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class CircularProgressView: UIView {
    
    @IBInspectable var radius: CGFloat = 20.0
    
    let circularProgressLayer: CAShapeLayer = {
        let circularProgress = CAShapeLayer()
        
        circularProgress.strokeColor = UIColor.whiteColor().CGColor
        circularProgress.fillColor = UIColor.clearColor().CGColor
        circularProgress.lineWidth = 4.0
        
        //circularProgress.path = UIBezierPath(ovalInRect: CGRect(x: 2, y: 2, width: 40, height: 40)).CGPath
        return circularProgress
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circularProgressLayer.frame = bounds
        setRadius()

    }
    
    func setRadius() {
        circularProgressLayer.path = UIBezierPath(roundedRect: CGRectMake(2, 2, radius * 2.0, radius * 2.0), cornerRadius: radius).CGPath
    }
    
    func show() {
        self.hidden = false
    }
    
    func hide() {
        self.hidden = true
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        layer.addSublayer(circularProgressLayer)
        
        let duration = 1.5
        
        let circularAnimationStart = CAKeyframeAnimation(keyPath: "strokeStart")
        circularAnimationStart.values = [0.0, 0.8, 1.0]
        circularAnimationStart.duration = duration
        circularAnimationStart.beginTime = duration / 1.5
        
        let circularAnimationStop = CAKeyframeAnimation(keyPath: "strokeEnd")
        circularAnimationStop.values = [0.0, 1.0]
        circularAnimationStop.duration = duration
        
        let circularAnimateColor = CAKeyframeAnimation(keyPath: "strokeColor")
        circularAnimateColor.values = [UIColor.blackColor().CGColor, UIColor.redColor().CGColor]
        circularAnimateColor.autoreverses = true
        
        let strokeAnimation = CAAnimationGroup()
        strokeAnimation.animations = [circularAnimationStart, circularAnimationStop, circularAnimateColor]
        strokeAnimation.duration = duration + circularAnimationStart.beginTime
        strokeAnimation.repeatCount = Float.infinity
        strokeAnimation.timeOffset = 0.2
        
        let circularRotation = CABasicAnimation(keyPath: "transform.rotation.z")
        circularRotation.duration = duration * 1.5
        circularRotation.fromValue = 0.0
        circularRotation.toValue = M_PI * 2
        circularRotation.repeatCount = Float.infinity
        circularRotation.timeOffset = 0.2
        
        circularProgressLayer.addAnimation(strokeAnimation, forKey: nil)
        circularProgressLayer.addAnimation(circularRotation, forKey: nil)

    }

}
