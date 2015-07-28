//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

@IBDesignable class CustomTextField: UITextField {
    
    @IBInspectable var cornerRadius: CGFloat = 10
    @IBInspectable var fillColor: UIColor = UIColor.clearColor()
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var strokeWidth: CGFloat = 1
    @IBInspectable var strokeColor: UIColor = UIColor.blackColor()
    
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
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        
        return CGRectInset(bounds, 10, 10)
        
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        
        return CGRectInset(bounds, 10, 10)
        
    }
    
}
