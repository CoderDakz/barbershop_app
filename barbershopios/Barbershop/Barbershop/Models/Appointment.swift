//
//  Appointment.swift
//  Barbershop
//
//  Created by user on 2017-06-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class Appointment : NSObject
{
    var style: [Style];
    var date: Date;
    var time: TimeSlot;
    var client: User;
    var barber: Barber;
    var pk : Int;
    var bio: String;
    var key: String;
    
    override init()
    {
        self.style = [Style]();
        self.date = Date();
        self.time = TimeSlot();
        self.client = User();
        self.barber = Barber();
        self.pk = 0;
        self.key = "";
        self.bio = "";
    }
    
    convenience init(style: [Style], date: Date, time: TimeSlot, client: User, barber: Barber, bio: String)
    {
        self.init();
        
        self.style = style;
        self.date = date;
        self.time = time;
        self.client = client;
        self.barber = barber;
        self.bio = bio;
        self.pk = 0;
        self.key = "";
        
    }
}
