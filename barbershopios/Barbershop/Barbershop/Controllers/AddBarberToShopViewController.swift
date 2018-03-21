//
//  AddBarberToShopViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-27.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddBarberToShopViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [String]();
    var resultKeys = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Set the delegates
        tableView.dataSource = self;
        tableView.delegate = self;
        searchBar.delegate = self;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        
        cell.textLabel?.text = searchResults[indexPath.row];
        
        return cell;
    }
    
    // If shop selects a barber, prompt them to add the barbers to their shop
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Add Barber", message: "Would you like to add this barber to your shop?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            
            // Add barber to our list of shops and also to the server
            let barber = Barber();
            
            barber.key = self.resultKeys[indexPath.row];
            
            (mainUser as! Shop).barbers.append(barber);
            
            let ref = Database.database().reference();
            
            ref.child("users").child(mainUser.key).child("barbers").childByAutoId().setValue(barber.key);
            
            self.navigationController?.popViewController(animated: true);
        }
        
        alertController.addAction(cancelAction);
        alertController.addAction(okayAction);
        
        present(alertController, animated: true, completion: nil);

    }
    
    // Display real-time search results
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let ref = Database.database().reference();
        
        self.searchResults.removeAll();
        self.resultKeys.removeAll();
        self.tableView.reloadData();
        
        if (searchText != "")
        {
            // Query the server by the name of the Barber, retrieve the results, and display it to the user
            ref.child("users").queryOrdered(byChild: "fullname").queryStarting(atValue: searchText).queryEnding(atValue: searchText + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;
                
                if (value != nil)
                {
                    // For each barber in the result
                    for user in value!
                    {
                        let currentUser = user.value as! NSDictionary;
                        
                        // Check if the current user is a barber, then append the results to the designated arrays
                        let type = currentUser["type"] as! Int;
                        
                        if (type == 2)
                        {
                            self.searchResults.append(currentUser["fullname"] as! String);
                            self.resultKeys.append(user.key as! String);
                            
                            self.tableView.reloadData();
                        }
                    }
                }
                
            });
        }
        
    }
}
