//
//  BookAppointmentNavigationController.swift
//  Barbershop
//
//  Created by user on 2017-06-26.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class BookAppointmentNavigationController : UINavigationController
{
    var user : Shop?;
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set the user in Select Appointment View Controller
        
        let vc = segue.destination as! SelectAppointmentDateViewController;
        vc.user = user;

    }
    
}
