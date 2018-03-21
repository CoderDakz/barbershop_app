//
//  Shop.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation

class Shop : User
{
    var rating: Double;
    var address: Address;
    var phoneNumber: String;
    var styles: [Style];
    var barbers: [Barber];
    var gallery: [String];
    var analytics: Analytics;
    var appointments: [String:[Appointment]];
    var distance: Double;
    var promotions: [Promotion];

    
    override init()
    {
        self.rating = 0.0;
        self.address = Address();
        self.phoneNumber = "";
        self.styles = [Style]();
        self.barbers = [Barber]();
        self.gallery = [String]();
        self.analytics = Analytics();
        self.appointments = [String:[Appointment]]();
        self.distance = 0.0;
        self.promotions = [Promotion]();
        
        super.init();
    }
}
