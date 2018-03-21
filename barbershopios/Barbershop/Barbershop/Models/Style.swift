//
//  Style.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import IGListKit

class Style : NSObject, ListDiffable
{
    var name: String;
    var details: String;
    var price: Double;
    var time: Int;
    var image: UIImage?;
    var key: String;
    var pk: Int;
    
    override init()
    {
        self.name = "";
        self.details = "";
        self.price = 0.0;
        self.pk = 0;
        self.time = 0;
        self.key = "";
    }
    
    convenience init(name: String, details: String, price: Double, primaryKey: Int)
    {
        self.init();
        
        self.name = name;
        self.details = details;
        self.price = price;
        self.pk = primaryKey;
        self.time = 0;
        self.key = "";
    }
    
    convenience init(name: String, details: String, price: Double, image: UIImage, primaryKey: Int)
    {
        self.init();
        
        self.name = name;
        self.details = details;
        self.price = price;
        self.image = image;
        self.pk = primaryKey;
        self.time = 0;
        self.key = "";

    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? Style else { return false }
        return name == object.name && details == object.details
            && price == object.price && time == object.time && key == object.key;
        
    }
    
    public func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }
}
