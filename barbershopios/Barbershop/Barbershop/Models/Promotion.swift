//
//  Promotion.swift
//  Barbershop
//
//  Created by user on 2017-06-24.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class Promotion : NSObject, ListDiffable
{
    var image : UIImage?;
    var bio : String;
    var pk : Int;
    var promoKey: String;
    var shopKey: String;
    
    override init()
    {
        self.image = nil;
        self.bio = "";
        self.pk = 0;
        self.promoKey = "";
        self.shopKey = "";
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? Promotion else { return false }
        return pk == object.pk && promoKey == object.promoKey && shopKey == object.shopKey;
    }
    
    public func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

}
