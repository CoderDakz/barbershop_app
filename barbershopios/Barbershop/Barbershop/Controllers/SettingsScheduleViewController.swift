//
//  SettingsScheduleViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-26.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SettingsScheduleViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    let pickerView = UIPickerView();
    let toolBar = UIToolbar();
    var alertController : UIAlertController!;
    var firstTime = 0;
    var secondTime = 0;
    var editedFirstTime = 0;
    var editedSecondTime = 0;
    var times = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Add delegate and data source for table view and picker view
        tableView.delegate = self;
        tableView.dataSource = self;
        
        pickerView.dataSource = self;
        pickerView.delegate = self;

        // Create a toolbar for the picker view that will close the picker view once "done" is pressed
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 23/255, green: 22/255, blue: 32/255, alpha: 1)
        toolBar.sizeToFit()

        // Create done button and space button so done can be positioned to the left
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        // Get all times in the barber's current schedule
        times = (mainUser as! Barber).schedule.returnScheduleAsReadableString().components(separatedBy: ",");
        
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func showAlertController(sender: UIBarButtonItem)
    {
        // Show the controller where users can enter in their own
        alertController = UIAlertController(title: "Search User", message: "Enter shop you want to search for?", preferredStyle: .alert);
        
        // First text field will have the start time
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Start time";
            textField.clearButtonMode = .whileEditing;
            textField.borderStyle = .roundedRect;
            textField.inputView = self.pickerView;
            textField.inputAccessoryView = self.toolBar;
        });
        
        // Second text field will have the end time
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "End time";
            textField.clearButtonMode = .whileEditing;
            textField.borderStyle = .roundedRect;
            textField.inputView = self.pickerView;
            textField.inputAccessoryView = self.toolBar;
        });
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        // If user selects okay, add the time to the schedule
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            // This isn't really booking an appointment, it's just setting the available times
            (mainUser as! Barber).schedule.addToSchedule(startTime: self.firstTime, endTime: self.secondTime);
            
            // Update barbers available times on the server
            let ref = Database.database().reference();
            
            ref.child("users").child(mainUser.key).child("schedule").setValue((mainUser as! Barber).schedule.scheduleToString());
            
            // Reload the Available Times list
            self.times = (mainUser as! Barber).schedule.returnScheduleAsReadableString().components(separatedBy: ",");

            self.tableView.reloadData();
        });
        
        // Add actions to alert controller and display it
        alertController.addAction(cancelAction);
        alertController.addAction(okayAction);

        present(alertController, animated: true, completion: nil);
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scheduleReadableTimes.count;
    }
    
    // Set time based on which text field is being used currently
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (alertController.textFields![0].isFirstResponder)
        {
            alertController.textFields![0].text = scheduleReadableTimes[row];
            firstTime = row;
        }
        else
        {
            alertController.textFields![1].text = scheduleReadableTimes[row];
            secondTime = row;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scheduleReadableTimes[row];
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // If user presses done, close the picker depending on which text field is showing
    func donePicker(sender: UIBarButtonItem)
    {
        if (alertController.textFields![0].isFirstResponder)
        {
            alertController.textFields![0].resignFirstResponder();
        }
        else
        {
            alertController.textFields![1].resignFirstResponder();
        }
    }
    
    // Display the amount of time ranges the user put in their schedule (we insert -1 since the last one is an empty string
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count - 1;
    }
    
    // Display time ranges in the schedule
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        
        cell.textLabel?.text = times[indexPath.row];
        
        return cell;
    }
    
    // This accomplishes the same actions as above, except this is for editing the selected time range
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alertController = UIAlertController(title: "Search User", message: "Enter shop you want to search for?", preferredStyle: .alert);
        
        let bothTimes = times[indexPath.row].components(separatedBy: " - ");
        editedFirstTime = TimeSlot().getIndexFromReadableTime(bothTimes[0]);
        editedSecondTime = TimeSlot().getIndexFromReadableTime(bothTimes[1]);
        firstTime = editedFirstTime;
        secondTime = editedSecondTime;

        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Start time";
            textField.clearButtonMode = .whileEditing;
            textField.borderStyle = .roundedRect;
            textField.inputView = self.pickerView;
            textField.inputAccessoryView = self.toolBar;
            textField.text = bothTimes[0];
        });
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "End time";
            textField.clearButtonMode = .whileEditing;
            textField.borderStyle = .roundedRect;
            textField.inputView = self.pickerView;
            textField.inputAccessoryView = self.toolBar;
            textField.text = bothTimes[1];
        });
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            // This isn't really booking an appointment, it's just setting the available times
            // (mainUser as! Barber).schedule.removeFromSchedule(startTime: scheduleTimes[self.firstTime], endTime: scheduleTimes[self.secondTime]);
            // (mainUser as! Barber).schedule.addToSchedule(startTime: scheduleTimes[self.firstTime], endTime: scheduleTimes[self.secondTime]);
            (mainUser as! Barber).schedule.removeFromSchedule(startTime: self.editedFirstTime, endTime: self.editedSecondTime);
            (mainUser as! Barber).schedule.addToSchedule(startTime: self.firstTime, endTime: self.secondTime);
            
            // Update barbers available times on the server
            let ref = Database.database().reference();
            
            ref.child("users").child(mainUser.key).child("schedule").setValue((mainUser as! Barber).schedule.scheduleToString());
            
            // Reload the Available Times list
            self.times = (mainUser as! Barber).schedule.returnScheduleAsReadableString().components(separatedBy: ",");
            
            self.tableView.reloadData();
        });
        
        alertController.addAction(cancelAction);
        alertController.addAction(okayAction);
        
        present(alertController, animated: true, completion: nil);

    }

}
