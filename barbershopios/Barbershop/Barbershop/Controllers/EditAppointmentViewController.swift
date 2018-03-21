//
//  EditAppointmentViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-21.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import Firebase

class EditAppointmentViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var appointmentTime: UITextField!
    @IBOutlet weak var cutDetails: UILabel!
    @IBOutlet weak var barberName: UITextField!
    @IBOutlet weak var clientName: UITextField!
    
    var appointment : Appointment?;
    var barberNames = [Barber]();
    var selectedTime = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        appointment = mainShop.appointments["temp"]!.first;
        
        calendar.select(appointment!.date);
        appointmentTime.text = appointment!.time.getFirstReadableTime();
        barberName.text = "\(appointment!.barber.firstName) \(appointment!.barber.lastName)";
        clientName.text = "\(appointment!.client.firstName) \(appointment!.client.lastName)";
        
        let pickerView = UIPickerView();
        pickerView.tag = 0;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        let pickerView2 = UIPickerView();
        pickerView2.tag = 1;
        pickerView2.dataSource = self;
        pickerView2.delegate = self;
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 23/255, green: 22/255, blue: 32/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        let toolBar2 = UIToolbar()
        toolBar2.barStyle = UIBarStyle.default
        toolBar2.isTranslucent = true
        toolBar2.tintColor = UIColor(red: 23/255, green: 22/255, blue: 32/255, alpha: 1)
        toolBar2.sizeToFit()
        
        let doneButton2 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker2(sender:)))
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar2.setItems([spaceButton2, doneButton2], animated: false)
        toolBar2.isUserInteractionEnabled = true

        appointmentTime.inputView = pickerView;
        appointmentTime.inputAccessoryView = toolBar;
        
        barberName.inputView = pickerView2;
        barberName.inputAccessoryView = toolBar2;
        
        grabBarbers();
        
        selectedTime = appointment!.time.getIndexFromReadableTime(appointment!.time.getFirstReadableTime());
        pickerView.selectRow(selectedTime, inComponent: 0, animated: false);
        
    }
    
    func grabBarbers()
    {
        
        if ((mainUser as! Shop).barbers.count != 0 && (mainUser as! Shop).barbers[0].firstName != "")
        {
            print("I'm here");
            grabUser();
            return;
        }
        
        for barber in (mainUser as! Shop).barbers
        {
            let ref = Database.database().reference();
            
            ref.child("users").child(barber.key).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                
                if (value != nil)
                {
                    print("Nah, I'm here");

                    barber.schedule.stringToSchedule(string: value!["schedule"] as! String);
                    barber.firstName = value!["fullname"] as! String;
                    barber.username = value!["username"] as! String;
                    barber.key = snapshot.key;
                    
                    self.barberNames.append(barber);
                }
                
                (mainUser as! Shop).barbers = self.barberNames;
                
                if (barber.key == self.appointment!.barber.key)
                {
                    self.barberName.text = barber.firstName;
                }
                
                
            });
        }
        
        grabUser();
    }
    
    func grabUser()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(appointment!.client.key).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            if (value != nil)
            {
                self.appointment!.client.firstName = value!["fullname"] as! String;
                print(self.appointment!.client.firstName);
                self.clientName.text = self.appointment!.client.firstName;
            }
            
        });
    }
    
    @IBAction func close(sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func doneButton(sender: UIBarButtonItem)
    {
        let ref = Database.database().reference();
        
        let newAppointment = Appointment();
        
        for barber in (mainUser as! Shop).barbers
        {
            if (barber.firstName == barberName.text)
            {
                newAppointment.barber = barber;
            }
        }
        
        newAppointment.client = appointment!.client;
        newAppointment.date = calendar.selectedDate!;
        newAppointment.key = appointment!.key;
        newAppointment.bio = appointment!.bio;
        newAppointment.style = appointment!.style;
        
        if (appointmentTime.text != appointment!.time.getFirstReadableTime())
        {
            newAppointment.time = TimeSlot();
            newAppointment.time.bookAppointment(startTime: selectedTime, endTime: selectedTime + 4);
        }
        else
        {
            newAppointment.time = appointment!.time;
        }
        var styles = "";
        
        for style in newAppointment.style
        {
            styles += style.key;
        }
        
        // Remove old from server
        
        ref.child("users").child(mainUser.key).child("appointments").child(shortDateFormatter.string(from: appointment!.date)).child(appointment!.key).removeValue();
        
        // Upload to server
        
        let paramToSend = ["barberid" : newAppointment.barber.key, "userid" : newAppointment.client.key, "styles" : styles, "time" : newAppointment.time.scheduleToString(), "date" : shortDateFormatter.string(from: newAppointment.date)];
        
        ref.child("users").child(mainUser.key).child("appointments").child(shortDateFormatter.string(from: newAppointment.date)).child(newAppointment.key).setValue(paramToSend);
        
        // Get variables needed to remove from mainUser
        let currentDate = shortDateFormatter.string(from: appointment!.date);
        let newDate = shortDateFormatter.string(from: newAppointment.date);
        let index = (mainUser as! Shop).appointments[currentDate]?.index(of: appointment!);
        
        // Remove old appointment from mainUser variable
        (mainUser as! Shop).appointments[currentDate]!.remove(at: index!);
        
        // Add new appointment to appointments list
        if ((mainUser as! Shop).appointments[newDate] == nil)
        {
            (mainUser as! Shop).appointments[newDate] = [Appointment]();
        }
        
        (mainUser as! Shop).appointments[newDate]!.append(newAppointment);

        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func cancelButton()
    {
        let alertController = UIAlertController(title: "Cancel Appointment", message: "Would you like to cancel this appointment?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
        }
        
        let okayAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            // Add barber to our list of shops and also to the server
            let ref = Database.database().reference();
            
            ref.child("users").child(mainUser.key).child("appointments").child(shortDateFormatter.string(from: self.appointment!.date)).child(self.appointment!.key).removeValue();
            
            let currentDate = shortDateFormatter.string(from: self.appointment!.date);
            let index = (mainUser as! Shop).appointments[currentDate]?.index(of: self.appointment!);
            
            (mainUser as! Shop).appointments[currentDate]!.remove(at: index!);
            
            self.dismiss(animated: true, completion: nil);

        }
        
        alertController.addAction(cancelAction);
        alertController.addAction(okayAction);
        
        present(alertController, animated: true, completion: nil);
    }
    
    @IBAction func completeAppointment()
    {
        let alertController = UIAlertController(title: "Complete Appointment", message: "Confirm that this appointment has been completed?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
        }
        
        let okayAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            // Add barber to our list of shops and also to the server
            let ref = Database.database().reference();

            ref.child("users").child(mainUser.key).child("appointments").child(shortDateFormatter.string(from: self.appointment!.date)).child(self.appointment!.key).removeValue();
            ref.child("users").child(self.appointment!.client.key).child("mandatoryReviews").childByAutoId().setValue(mainUser.key);
            
            let currentDate = shortDateFormatter.string(from: self.appointment!.date);
            let index = (mainUser as! Shop).appointments[currentDate]?.index(of: self.appointment!);
            
            (mainUser as! Shop).appointments[currentDate]!.remove(at: index!);

            self.dismiss(animated: true, completion: nil);
        }
        
        alertController.addAction(cancelAction);
        alertController.addAction(okayAction);
        
        present(alertController, animated: true, completion: nil);
    }
    
    @IBAction func editBarber(sender: UIButton)
    {
        barberName.becomeFirstResponder();
    }
    
    @IBAction func completedAppointment(sender: UIButton)
    {
        let ref = Database.database().reference();
        
        ref.child(mainUser.key).child("appointments").child(shortDateFormatter.string(from: appointment!.date)).child(appointment!.key).removeValue();
        ref.child(appointment!.client.key).child("mandatoryReviews").childByAutoId().setValue(mainUser.key);
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView.tag == 0)
        {
            return scheduleTimes.count;
        }
        else
        {
            return barberNames.count;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 0)
        {
            appointmentTime.text = scheduleReadableTimes[row];
            selectedTime = row;
        }
        else
        {
            barberName.text = barberNames[row].firstName;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0)
        {
            return scheduleReadableTimes[row];
        }
        else
        {
            return barberNames[row].firstName;
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func donePicker(sender: UIBarButtonItem)
    {
        appointmentTime.resignFirstResponder();
    }
    
    func donePicker2(sender: UIBarButtonItem)
    {
        barberName.resignFirstResponder();
    }
}
