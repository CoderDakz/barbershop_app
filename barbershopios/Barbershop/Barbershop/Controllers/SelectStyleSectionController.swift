//
//  SelectStyleSectionController.swift
//  Barbershop
//
//  Created by user on 2017-06-19.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class SelectStyleSectionController : ListSectionController
{
    private var object: Style!
    
    var vc : UIViewController?;
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1;
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 375, height: 152)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: "SelectStyleCell", for: self, at: index) as! SelectStyleCell;
        cell.styleTitle.text = object.name;
        cell.styleImage.image = object.image;
        cell.stylePrice.text = "$\(String(format: "%.02f", object.price))";
        cell.styleTime.text = timeIntervals[object.time];
        
        cell.layer.borderColor = UIColor.gray.cgColor;
        cell.layer.borderWidth = 1;
        cell.layer.masksToBounds = false;

        return cell;
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as! Style;
    }
    
    override func didSelectItem(at index: Int) {
        
        let alertController = UIAlertController(title: "Details", message: object.details, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        let addAction = UIAlertAction(title: "Add to cart", style: .default) { (action) in
            styleCart.append(self.object);
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "stylepressed"), object: self)

        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction);
        
        vc?.present(alertController, animated: true, completion: nil);
    }


}
