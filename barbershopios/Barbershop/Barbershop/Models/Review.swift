//
//  Review.swift
//  Barbershop
//
//  Created by user on 2017-06-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class Review : NSObject, ListDiffable
{
    var rating: Double;
    var user_id: String;
    var review: String;
    var pk: Int;
    
    override init()
    {
        self.rating = 0.0;
        self.user_id = "";
        self.review = "";
        self.pk = 0;
        
        super.init();
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? Review else { return false }
        return rating == object.rating && user_id == object.user_id
            && review == object.review && pk == object.pk;
    }
    
    public func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }
}
