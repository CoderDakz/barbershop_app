//
//  ReviewSectionController.swift
//  Barbershop
//
//  Created by user on 2017-06-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class ReviewSectionController : ListSectionController
{
    private var object : Review?;
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1;
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 345, height: 148)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: "ReviewCell", for: self, at: index) as! ReviewCell;

        cell.ratings.rating = object!.rating;
        cell.review.text = object!.review;
        cell.userName.text = "Review by: " + object!.user_id;
        
        cell.layer.borderColor = UIColor.gray.cgColor;
        cell.layer.borderWidth = 1;
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath;
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowRadius = 1
        cell.layer.shouldRasterize = true;

        return cell;
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as! Review;
    }
    
    override func didSelectItem(at index: Int) {
        
    }

}
