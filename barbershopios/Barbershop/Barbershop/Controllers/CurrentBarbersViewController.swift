//
//  CurrentBarbersViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-27.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CurrentBarbersViewController : UITableViewController
{
    override func viewDidLoad() {
        super.viewDidLoad();
        
        grabBarbers();
    }
    
    // MARK: Custom functions
    
    // Grab the information of each barber inside our main user's barbers list
    func grabBarbers()
    {
        // If first name isn't blank, that means barbers are already listed
        if ((mainUser as! Shop).barbers.count != 0 && (mainUser as! Shop).barbers[0].firstName != "")
        {
            return;
        }
        
        var barbers = [Barber]();
        
        // Loop through each barber and get required information from the server
        for barber in (mainUser as! Shop).barbers
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

                    barbers.append(barber);
                }
                
                (mainUser as! Shop).barbers = barbers;
                
                print((mainUser as! Shop).barbers);
                self.tableView.reloadData();

            });
        }
        
    }
    
    // MARK: Delegate and Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mainUser as! Shop).barbers.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        
        cell.textLabel?.text = "\((mainUser as! Shop).barbers[indexPath.row].firstName) \((mainUser as! Shop).barbers[indexPath.row].lastName)";
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete)
        {
            let ref = Database.database().reference();
            
            let barber = (mainUser as! Shop).barbers[indexPath.row];
            (mainUser as! Shop).barbers.remove(at: indexPath.row);
            
            ref.child("users").child(mainUser.key).child("barbers").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as! NSDictionary;
                
                for barb in (value)
                {
                    if ((barb.value as! String) == barber.key)
                    {
                        ref.child("users").child(mainUser.key).child("barbers").child(barb.key as! String).removeValue();
                        
                        self.tableView.deleteRows(at: [indexPath], with: .automatic);
                    }
                }
            });
        }
    }
}
