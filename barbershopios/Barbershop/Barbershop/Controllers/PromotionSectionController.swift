//
//  PromotionSectionController.swift
//  Barbershop
//
//  Created by user on 2017-06-24.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import Firebase
import Kingfisher
// import FirebaseStorageUI

class PromotionSectionController : ListSectionController
{
    private var object : Promotion?;
    
    var vc : PromotionsViewController?;
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1;
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 338, height: 199)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: "PromotionCell", for: self, at: index) as! PromotionCell;


        if (object!.image == nil)
        {
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + object!.shopKey + "/promotions/" + object!.promoKey);
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    cell.imageView.kf.setImage(with: url);
                }
            });
        }
        else
        {
            cell.imageView.image = object!.image;
        }
        
        cell.bio.text = object!.bio;
        
        cell.layer.borderColor = UIColor.gray.cgColor;
        cell.layer.borderWidth = 1;
        cell.layer.masksToBounds = false;
        /* cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath;
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowRadius = 1
        cell.layer.shouldRasterize = true; */

        return cell;
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as! Promotion;
    }
    
    override func didSelectItem(at index: Int) {
        vc!.promotion = object!;
        vc!.performSegue(withIdentifier: "NewPromotionSegue", sender: vc!);
    }
    
}
