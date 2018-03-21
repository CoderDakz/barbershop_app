//
//  SelectAppointmentDateViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import Firebase

class SelectAppointmentDateViewController: UIViewController, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var nextButton: UIButton!
    
    var appointment = Appointment();
    var timeSelectedIndex = 0;
    
    var user : Shop?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        user = mainShop;
        
        calendar.delegate = self;
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        
        self.navigationItem.backBarButtonItem = backButton;
        
        appointment.client = User();
        appointment.client.key = mainUser.key;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AvailableBarberSegue")
        {
            let vc = segue.destination as! SelectBarberViewController;
                        
            vc.appointment = self.appointment;
            vc.user = self.user;
        }
    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil);
    }
    
    // MARK: Delegate Functions
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        nextButton.isHidden = false;
        appointment.date = date;
    }
    

}
