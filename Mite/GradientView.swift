//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.whiteColor()
    @IBInspectable var secondColor: UIColor = UIColor.blackColor()
    
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)
    
    override func drawRect(rect: CGRect) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = layer.bounds
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = [firstColor.CGColor, secondColor.CGColor]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
    }
    
}