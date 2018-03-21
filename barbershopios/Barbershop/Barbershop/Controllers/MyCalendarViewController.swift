//
//  MyCalendarViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import Firebase

class MyCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dayBookingsLabel: UILabel!
    @IBOutlet weak var bookingAmountLabel: UILabel!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let formatter : DateFormatter = {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy";
        return dateFormatter;
    }();
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        calendar.delegate = self;
        
        emptyToday();
        
        bookingAmountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(todayClick)))
    }
    
    func emptyToday()
    {
        bookingAmountLabel.text = "No clients booked";
    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);
        // dismiss(animated: true, completion: nil);
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let currentDate = self.dateFormatter.string(from: date);
        
        dayBookingsLabel.text = formatter.string(from: date);
        
        if (mainUser.type == 3)
        {
            if let appointments = (mainUser as! Shop).appointments[currentDate]
            {
                if (appointments.count != 0)
                {
                    bookingAmountLabel.text = "You have \(appointments.count) appointments booked for this day.";
                }
                else
                {
                    bookingAmountLabel.text = "You have no appointments booked for this day.";
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let currentDate = self.dateFormatter.string(from: date);
        
        if (mainUser.type == 3)
        {
            if (mainUser as! Shop).appointments[currentDate] != nil
            {
                return UIColor.gray;
            }
        }
        
        return nil;
    }
    
    func todayClick()
    {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageBookingsViewController") as! ManageBookingsViewController;
        
        vc.date = calendar.selectedDate;
        vc.currentDateAppointments = ((mainUser as! Shop).appointments[shortDateFormatter.string(from: calendar.selectedDate!)])!;
        
        self.viewDeckController?.centerViewController = vc;
    }
}
