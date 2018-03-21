//
//  Models.swift
//  Barbershop
//
//  Created by user on 2017-05-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation

class Position : NSObject
{
    var latitude : Double;
    var longitude : Double;
    
    override init()
    {
        self.latitude = 0.0;
        self.longitude = 0.0;
        
        super.init();
    }
    
    convenience init(latitude: Double, longitude: Double)
    {
        self.init();
        
        self.latitude = latitude;
        self.longitude = longitude;
    }
}
