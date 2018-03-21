//
//  SearchViewController.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class SearchViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func back()
    {
        
        self.viewDeckController?.open(.left, animated: true);
        
        // self.dismiss(animated: true, completion: nil);
    }
    
    let menuOptions = ["Location", "Name", "Top Rated", "Near Me", "Map"];
    let menuImages = [#imageLiteral(resourceName: "ic_search_location"), #imageLiteral(resourceName: "ic_search_name"), #imageLiteral(resourceName: "ic_search_top_rated"), #imageLiteral(resourceName: "ic_search_near_me"), #imageLiteral(resourceName: "ic_search_map")];
    var listOfShops = [Shop]();
    let locationManager = CLLocationManager()
    private var latitude: Double?;
    private var longitude: Double?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        tableView.tableFooterView = UIView();

        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableCell", for: indexPath) as! SearchTableCell;
        
        cell.titleLabel.text = menuOptions[indexPath.row];
        cell.iconView.image = menuImages[indexPath.row];
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.listOfShops.removeAll();
        
        if (indexPath.row == 0)
        {
            // If Location has been chosen
            self.performSegue(withIdentifier: "locationSegue", sender: self);
        }
        else if (indexPath.row == 1)
        {
            // If search by name has been chosen
            
            let alertController = UIAlertController(title: "Search User", message: "Enter shop you want to search for?", preferredStyle: .alert);
            
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Barber shop name";
                textField.clearButtonMode = .whileEditing;
                textField.borderStyle = .roundedRect;
            });
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                
                // Get name user has chosen
                let query = alertController.textFields?[0].text!;
                
                var newListOfShops = [Shop]();
                
                
                let ref = Database.database().reference();
                
                /*
                  Search through the database for the shop name that has the query. Search by type 3 which is the shops.
                 \u{f8ff} is some next hex code that I forgot but it makes search works
                 */
                ref.child("users").queryOrdered(byChild: "shopname").queryStarting(atValue: query).queryEnding(atValue: query! + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // Get the current snapshot which is a Dictionary of the search results in the database. Create the unique key variable
                    
                    let value = snapshot.value as? NSDictionary
                    var i = 0;
                    
                    if (value != nil)
                    {
                        // Loop through each shop in the search results
                        for user in value!
                        {
                            
                            // Create the shop and add it to our list of shops.
                            let currentUser = user.value as! NSDictionary;
                            
                            let type = currentUser["type"] as! Int;
                            
                            if (type == 3)
                            {
                                let shop = Shop();
                                shop.username = currentUser["username"] as! String;
                                shop.firstName = currentUser["shopname"] as! String;
                                shop.rating = currentUser["rating"] as! Double;
                                shop.email = currentUser["email"] as! String;
                                shop.key = user.key as! String;
                                shop.address = Address();
                                shop.address.fullAddress = currentUser["shopaddress"] as! String;
                                shop.pk = i;
                                
                                if (currentUser["aboutus"] != nil)
                                {
                                    shop.bio = currentUser["aboutus"] as! String;
                                }
                                
                                if (currentUser["phonenumber"] != nil)
                                {
                                    shop.phoneNumber = currentUser["phonenumber"] as! String;
                                }

                                if (currentUser["latitude"] != nil)
                                {
                                    shop.latitude = currentUser["latitude"] as! Double;
                                }
                                
                                if (currentUser["longitude"] != nil)
                                {
                                    shop.longitude = currentUser["longitude"] as! Double;
                                }
                                
                                let barberShot = currentUser["barbers"] as? NSDictionary;
                                
                                if (barberShot != nil)
                                {
                                    var barber : Barber;
                                    
                                    for barbers in (barberShot!.allValues as! [String])
                                    {
                                        barber = Barber();
                                        
                                        barber.key = barbers;
                                        
                                        shop.barbers.append(barber);
                                    }
                                }

                                i += 1;
                                newListOfShops.append(shop);
                            }
                        }
                    }
                    
                    // Present the search results
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController;
                    
                    viewController.searchResults = newListOfShops;
                    
                    self.present(viewController, animated: true, completion: nil);

                });
            });

            alertController.addAction(cancelAction)
            alertController.addAction(okayAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
        else if (indexPath.row == 2)
        {
            // Sort through rating based on highest rating first
            let ref = Database.database().reference();
            
            ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                var i = 0;
                
                if (value != nil)
                {
                    // Loop through each shop in the search results
                    for user in value!
                    {
                        // Create the shop and add it to our list of shops.
                        let currentUser = user.value as! NSDictionary;
                        let type = currentUser["type"] as! Int;
                        
                        if (type == 3)
                        {
                            let shop = Shop();
                            shop.username = currentUser["username"] as! String;
                            shop.firstName = currentUser["shopname"] as! String;
                            shop.rating = currentUser["rating"] as! Double;
                            shop.email = currentUser["email"] as! String;
                            shop.address = Address();
                            shop.address.fullAddress = currentUser["shopaddress"] as! String;
                            shop.key = user.key as! String;
                            shop.pk = i;
                            
                            if (currentUser["aboutus"] != nil)
                            {
                                shop.bio = currentUser["aboutus"] as! String;
                            }
                            
                            if (currentUser["phonenumber"] != nil)
                            {
                                shop.phoneNumber = currentUser["phonenumber"] as! String;
                            }
                            
                            if (currentUser["latitude"] != nil)
                            {
                                shop.latitude = currentUser["latitude"] as! Double;
                            }
                            
                            if (currentUser["longitude"] != nil)
                            {
                                shop.longitude = currentUser["longitude"] as! Double;
                            }
                            
                            let barberShot = currentUser["barbers"] as? NSDictionary;
                            
                            if (barberShot != nil)
                            {
                                var barber : Barber;
                                
                                for barbers in (barberShot!.allValues as! [String])
                                {
                                    barber = Barber();
                                    
                                    barber.key = barbers;
                                    
                                    shop.barbers.append(barber);
                                }
                            }
                            
                            print(currentUser);
                            
                            
                            i += 1;
                            self.listOfShops.append(shop);

                        }
                    }
                    
                    self.listOfShops = self.listOfShops.sorted(by: {($0.rating > $1.rating)});

                    // present the search results
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController;
                    
                    viewController.searchResults = self.listOfShops;
                    
                    self.present(viewController, animated: true, completion: nil);

                }
                
            });
        }
        else if (indexPath.row == 3)
        {
            let ref = Database.database().reference();
            
            ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                // Get the current snapshot which is a Dictionary of the search results in the database. Create the unique key variable
                
                let value = snapshot.value as? NSDictionary
                var i = 0;
                
                if (value != nil)
                {
                    // Loop through each shop in the search results
                    for user in value!
                    {
                        
                        // Create the shop and add it to our list of shops.
                        let currentUser = user.value as! NSDictionary;
                        
                        let type = currentUser["type"] as! Int;
                        
                        if (type == 3)
                        {
                            let shop = Shop();
                            shop.username = currentUser["username"] as! String;
                            shop.firstName = currentUser["shopname"] as! String;
                            shop.rating = currentUser["rating"] as! Double;
                            shop.email = currentUser["email"] as! String;
                            shop.key = user.key as! String;
                            shop.address = Address();
                            shop.address.fullAddress = currentUser["shopaddress"] as! String;
                            
                            if (currentUser["latitude"] != nil)
                            {
                                shop.latitude = currentUser["latitude"] as! Double;
                            }
                            
                            if (currentUser["longitude"] != nil)
                            {
                                shop.longitude = currentUser["longitude"] as! Double;
                            }
                            
                            if (self.latitude != nil || self.longitude != nil)
                            {
                                let distance1 = CLLocation(latitude: self.latitude!, longitude: self.longitude!);
                                let distance2 = CLLocation(latitude: shop.latitude!, longitude: shop.longitude!);
                                
                                shop.distance = distance1.distance(from: distance2)/1000;
                            }
                            else
                            {
                                shop.distance = 0;
                            }
                            
                            if (currentUser["aboutus"] != nil)
                            {
                                shop.bio = currentUser["aboutus"] as! String;
                            }
                            
                            if (currentUser["phonenumber"] != nil)
                            {
                                shop.phoneNumber = currentUser["phonenumber"] as! String;
                            }

                            let barberShot = currentUser["barbers"] as? NSDictionary;
                            
                            if (barberShot != nil)
                            {
                                var barber : Barber;
                                
                                for barbers in (barberShot!.allValues as! [String])
                                {
                                    barber = Barber();
                                    
                                    barber.key = barbers;
                                    
                                    shop.barbers.append(barber);
                                }
                            }
                            
                            shop.pk = i;
                            
                            i += 1;
                            self.listOfShops.append(shop);
                        }
                    }
                    
                    self.listOfShops = self.listOfShops.sorted(by: {($0.distance < $1.distance)});

                }
                
                // Present the search results
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController;
                
                viewController.searchResults = self.listOfShops;
                
                self.present(viewController, animated: true, completion: nil);
                
            });
        }
        else if (indexPath.row == 4)
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController");
            
            self.present(viewController, animated: true, completion: nil); 
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;
    }
}
