//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 10
    @IBInspectable var fillColor: UIColor = UIColor.clearColor()
    @IBInspectable var strokeColor: UIColor = UIColor.blackColor()
    @IBInspectable var strokeWidth: CGFloat = 1
    
    override func drawRect(rect: CGRect) {
        
        //layer within the view
        var context = UIGraphicsGetCurrentContext()
        let insetRect = CGRectInset(rect, strokeWidth / 2, strokeWidth / 2)
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: cornerRadius)
    
        //filling the object with color
        fillColor.set()
        
        CGContextAddPath(context, path.CGPath)
        CGContextFillPath(context)
        
        //drawing the outline of the object
        strokeColor.set()
        
        CGContextSetLineWidth(context, strokeWidth)
        CGContextAddPath(context, path.CGPath)
        CGContextStrokePath(context)
    
        
    }
    
}
