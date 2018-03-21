//
//  SelectBarberViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-18.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SelectBarberViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var appointmentTime: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var appointment : Appointment?;
    var user : Shop?;
    var timeSelectedIndex = 32;
    
    var barbers = [Barber]();
    var availableBarbers = [Barber]();
    let pickerView = UIPickerView();
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;
        
        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;
        
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 23/255, green: 22/255, blue: 32/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        appointmentTime.inputView = pickerView;
        appointmentTime.inputAccessoryView = toolBar;
        
        tableView.tableFooterView = UIView();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        nextButton.isHidden = true;
        
        grabBarbers();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ChooseStyleSegue")
        {
            self.appointment!.time.bookAppointment(startTime: timeSelectedIndex, endTime: timeSelectedIndex + 4);
            
            let vc = segue.destination as! SelectStyleViewController;
            
            vc.appointment = self.appointment;
            vc.user = user;
        }
    }
    
    func grabBarbers()
    {
        if (user!.barbers.count != 0 && user!.barbers[0].firstName != "")
        {
            self.barbers = user!.barbers;
            
            return;
        }
        
        for barber in user!.barbers
        {
            let ref = Database.database().reference();
            
            ref.child("users").child(barber.key).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                
                if (value != nil)
                {
                    barber.schedule.stringToSchedule(string: value!["schedule"] as! String);
                    barber.firstName = value!["fullname"] as! String;
                    barber.username = value!["username"] as! String;
                    barber.key = snapshot.key;
                    
                    self.barbers.append(barber);
                }
                
                self.user!.barbers = self.barbers;
                
                self.tableView.reloadData();
            });
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barbers.count;
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        appointment?.barber = Barber();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectBarberCell", for: indexPath) as! SelectBarberCell;
        
        cell.barberName.text = barbers[indexPath.row].firstName;
        
        if (barbers[indexPath.row].schedule.isAvailable(timeSelectedIndex, 1))
        {
            cell.availableTime.text = "Available";
        }
        else
        {
            cell.availableTime.text = scheduleReadableTimes[barbers[indexPath.row].schedule.getNextAvailableReadableTime(timeSelectedIndex)];
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nextButton.isHidden = false;

        // Place selected barber inside appointment
        appointment?.barber = barbers[indexPath.row];
        
        if (!barbers[indexPath.row].schedule.isAvailable(timeSelectedIndex, 1))
        {
            timeSelectedIndex = barbers[indexPath.row].schedule.getNextAvailableReadableTime(timeSelectedIndex);
        }
        
        appointmentTime.text = scheduleReadableTimes[timeSelectedIndex];
        pickerView.selectRow(timeSelectedIndex, inComponent: 0, animated: false);
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scheduleReadableTimes.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        appointmentTime.text = scheduleReadableTimes[row];
        timeSelectedIndex = row;
        
        /* availableBarbers.removeAll();
         
         for barber in barbers
         {
         if (barber.schedule.isAvailable(row, 1))
         {
         availableBarbers.append(barber);
         
         }
         } */
        
        tableView.reloadData();
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scheduleReadableTimes[row];
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func donePicker(sender: UIBarButtonItem)
    {
        appointmentTime.resignFirstResponder();
    }
}
