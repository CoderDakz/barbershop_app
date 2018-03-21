//
//  Barber.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation

class Barber : User
{
    var ratings: Int;
    var schedule: TimeSlot;
    var appointments: [String:[Appointment]];
    
    override init()
    {
        self.ratings = 0;
        self.schedule = TimeSlot();
        self.appointments = [String:[Appointment]]();
        
        super.init();
    }
}
