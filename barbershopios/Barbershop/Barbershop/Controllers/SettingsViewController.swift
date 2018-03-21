//
//  SettingsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-23.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import Firebase

class SettingsViewController : UITableViewController
{
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.tableFooterView = UIView();

        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        self.navigationController?.navigationBar.barStyle = .black;
        self.navigationController?.navigationBar.tintColor = .black;

    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);

        // dismiss(animated: true, completion: nil);
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         If type = 2, then we load Barber settings. If type = 3, then we load Shop settings.
        */
        
        switch (section)
        {
            case 0:
                if (mainUser.type == 2)
                {
                    return 1;
                }
                else if (mainUser.type == 3)
                {
                    return 3;
                }
                else
                {
                    return 0;
                }
            case 1:
                return 2;
            default:
                return 0;
        }
    }
    
    // Set the setting names for each setting depending on the user account
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
                
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            if (mainUser.type == 3)
            {
                cell.textLabel?.text = "Add Barbers to Shop";
            }
            else if (mainUser.type == 2)
            {
                cell.textLabel?.text = "Edit Schedule";
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            cell.textLabel?.text = "Edit Styles";
        }
        else if (indexPath.section == 0 && indexPath.row == 2)
        {
            cell.textLabel?.text = "View Reviews";
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            cell.textLabel?.text = "Edit Profile";
        }
        else if (indexPath.section == 1 && indexPath.row == 1)
        {
            cell.textLabel?.text = "Logout";
        }
        
        return cell;
    }
    
    // Have two sections: Last one will be everyone's settings, first one is settings depending on user
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            // If shop, display the Add Barber option. If Barber, display the Set Schedule option
            if (mainUser.type == 3)
            {
                performSegue(withIdentifier: "AddBarber", sender: self);
            }
            else
            {
                let viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SettingsScheduleViewController");
                
                self.present(viewController, animated: true, completion: nil);
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            // Show Edit Styles view controller
            let viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "StyleSettingsNavigation");
            
            self.present(viewController, animated: true, completion: nil);

        }
        else if (indexPath.section == 0 && indexPath.row == 2)
        {
            // Grab all reviews the barber has and display the reviews
            let ref = Database.database().reference();
            
            ref.child(mainUser.key).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                var allReviews = [Review]();
                
                if (value != nil)
                {
                    for review in value!
                    {
                        let currReview = Review();
                        let currentReview = review.value as! NSDictionary;
                        
                        currReview.rating = currentReview["rating"] as! Double;
                        currReview.review = currentReview["review"] as! String;
                        currReview.user_id = currentReview["user_id"] as! String;
                        
                        allReviews.append(currReview);
                    }
                    
                }
                
                let viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ViewRatingsViewController") as! ViewRatingsViewController;
                
                viewController.reviews = allReviews;
                
                self.present(viewController, animated: true, completion: nil);
                
            });
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            // This is where the Edit profile view controller goes
            
            self.performSegue(withIdentifier: "EditProfileSegue", sender: self);

        }
        else if (indexPath.section == 1 && indexPath.row == 1)
        {
            // Log the user out
            let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            }
            
            let addAction = UIAlertAction(title: "Yes", style: .default) { (action) in

                let preferences = UserDefaults.standard
                preferences.removeObject(forKey: "user_id")
                
                self.view.makeToast("Successfully Logged Out...", duration: 2.0, position: .center)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                    {
                        
                        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController");
                        
                        self.present(viewController, animated: true, completion: nil);
                })
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(addAction);
            
            present(alertController, animated: true, completion: nil);

        }
    }
    
    // Display the title for each header
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section)
        {
            case 0:
                return "Settings";
            case 1:
                return "Other";
            default:
                return "";
            
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView();
        header.textLabel?.textColor = UIColor.black;
        
        return header;
    }
}
