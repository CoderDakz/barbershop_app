//
//  Address.swift
//  Barbershop
//
//  Created by user on 2017-05-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation

class Address : NSObject
{
    var streetNumber : String;
    var streetName : String;
    var city : String;
    var state : String;
    var country : String;
    var postalCode : String;
    var location : Position;
    var fullAddress: String;
    
    
    override init()
    {
        self.streetNumber = "";
        self.streetName = "";
        self.city = "";
        self.state = "";
        self.country = "";
        self.postalCode = "";
        self.location = Position();
        self.fullAddress = "";
        
        super.init();
    }
    
    convenience init(streetNumber: String, streetName: String, city: String, state: String, country: String, postalCode: String, location: Position)
    {
        self.init();
        
        self.streetNumber = streetNumber;
        self.streetName = streetName;
        self.city = city;
        self.state = state;
        self.country = country;
        self.postalCode = postalCode;
        self.location = location;
        self.fullAddress = "";
        
    }
}
