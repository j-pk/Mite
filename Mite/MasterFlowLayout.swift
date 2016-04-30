//
//  Copyright (c) 2015 Parker Kirby. All rights reserved.
//

import UIKit

protocol MainLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    
}

class MainLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var photoHeight: CGFloat = 0
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! MainLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let attributes = object as? MainLayoutAttributes {
            
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class MasterFlowLayout: UICollectionViewFlowLayout {
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var visibleIndexPathSet: NSMutableSet!
    private var latestDelta: CGFloat!
    
    var currentCellPath: NSIndexPath?
    var currentCellCenter: CGPoint?
    var currentCellScale: CGFloat?
    
    var delegate: MainLayoutDelegate!
    var numberOfColumns = 1
    var cellPadding: CGFloat = 0
    
    var cache = [MainLayoutAttributes]()
    var contentHeight: CGFloat = 0
    var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var width: CGFloat = 0
    var viewWidth: CGFloat { return width - (insets.left + insets.right) }
    
    override class func layoutAttributesClass() -> AnyClass {
        
        return MainLayoutAttributes.self
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: viewWidth, height: contentHeight)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.visibleIndexPathSet = NSMutableSet()
    }
    
    ///////////////////// Dynamic Begins \\\\\\\\\\\\\\\\\\\\
    
    override func prepareLayout() {
        super.prepareLayout()
        
        cache = []
        contentHeight = 0
            
            let columnWidth = viewWidth / CGFloat(numberOfColumns)
            
            //creating array of the x & y of previous columns to generate the proper cell frame for new ones
            //x is more less static since its width is based on column width
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
                
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            //y is dynamic so we need to continously get back the yOffset from the array
            var yOffsets = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            var column = 0
            for item in 0..<collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                let width = columnWidth - (cellPadding * 2)
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding + photoHeight + annotationHeight + cellPadding
                let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                let attributes = MainLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = insetFrame
                attributes.photoHeight = photoHeight
                cache.append(attributes)
                //base height off the tallest column
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffsets[column] = yOffsets[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
        
        }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
}
