//
//  ManageBookingsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-07.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import Firebase

class ManageBookingsViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentDateAppointments = [Appointment]();
    var date : Date?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        calendar.scope = .week;
        
        calendar.delegate = self;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        if (date != nil)
        {
            calendar.select(date);
            calendar.reloadData();
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if (calendar.selectedDate != nil)
        {
            let selectedDate = shortDateFormatter.string(from: calendar.selectedDate!);
            
            currentDateAppointments.removeAll();
            
            if let appointments = (mainUser as! Shop).appointments[selectedDate]
            {
                currentDateAppointments = appointments;
            }
            
            collectionView.reloadData();
            calendar.reloadData();

        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectedDate = shortDateFormatter.string(from: date);
        
        currentDateAppointments.removeAll();

        if let appointments = (mainUser as! Shop).appointments[selectedDate]
        {
            currentDateAppointments = appointments;
        }

        collectionView.reloadData();
    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);

        // dismiss(animated: true, completion: nil);
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size);
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let currentDate = shortDateFormatter.string(from: date);
        
        if (mainUser.type == 3)
        {
            if (mainUser as! Shop).appointments[currentDate] != nil && !(mainUser as! Shop).appointments[currentDate]!.isEmpty
            {
                return UIColor.gray;
            }
        }
        else if (mainUser.type == 2)
        {
            if (mainUser as! Barber).appointments[currentDate] != nil && !(mainUser as! Barber).appointments[currentDate]!.isEmpty
            {
                return UIColor.gray;
            }
        }
        
        
        return nil;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDateAppointments.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ManageBookingsCell", for: indexPath) as! ManageBookingsCell;
        
        let firstBookingTimeHour = currentDateAppointments[indexPath.row].time.getFirstReadableTime().substring(to: currentDateAppointments[indexPath.row].time.getFirstReadableTime().index(of: ":")!);
        
        cell.bookingTime.text = "\(firstBookingTimeHour) - \(currentDateAppointments[indexPath.row].time.getLastReadableTime())";
        
        cell.appointmentDescription.text = currentDateAppointments[indexPath.row].bio;

        if (currentDateAppointments[indexPath.row].barber.firstName == "")
        {
            let ref = Database.database().reference();
            
            print(currentDateAppointments[indexPath.row].barber.key);

            ref.child("users").child(currentDateAppointments[indexPath.row].barber.key).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                
                if (value != nil)
                {
                    self.currentDateAppointments[indexPath.row].barber.firstName = value!["fullname"] as! String;
                    
                    cell.userFirstName.text = self.currentDateAppointments[indexPath.row].barber.firstName;
                }
            });
        } 
                
        let ref = Storage.storage().reference(withPath: "users/" + currentDateAppointments[indexPath.row].barber.key + "/avatar.jpeg");
        
        ref.downloadURL(completion: { (url, error) in
            if (url != nil)
            {
                cell.userIcon.kf.setImage(with: url);
            }
        });
        
        cell.layer.borderColor = UIColor.gray.cgColor;
        cell.layer.borderWidth = 1.0;
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (mainUser.type == 3)
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditAppointmentNavigation");
            
            mainShop.appointments["temp"] = [Appointment]();
            mainShop.appointments["temp"]!.append(currentDateAppointments[indexPath.row]);
            
            self.present(viewController, animated: true, completion: nil);
        }
    }
}
