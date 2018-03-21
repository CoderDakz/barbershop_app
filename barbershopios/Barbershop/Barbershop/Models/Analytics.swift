//
//  Analytics.swift
//  Barbershop
//
//  Created by user on 2017-05-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation

class Analytics : NSObject
{
    var impressions : Int;
    var reach : Int;
    var interactions : Int;
    var bookedAppointments : Int;
    var cancelledAppointments : Int;
    
    override init()
    {
        self.impressions = 0;
        self.reach = 0;
        self.interactions = 0;
        self.bookedAppointments = 0;
        self.cancelledAppointments = 0;
    }
}
