//
//  SearchLocationViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-01.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SearchLocationViewController : UITableViewController
{
    let cities = ["Toronto", "Montreal", "Ottawa", "Brampton", "New York"];
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    var listOfCities = NSArray();
    var realCities = [Shop]();
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        realCities.removeAll();
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationCell", for: indexPath) as! SearchTableCell;
        
        cell.titleLabel.text = cities[indexPath.row];
        /* cell.selectedView.layer.cornerRadius = 25;
        cell.selectedView.layer.masksToBounds = true;
        cell.selectedView.tintColor = UIColor.gray;
        cell.selectedView.layer.borderWidth = 1.0;
        cell.selectedView.layer.borderColor = UIColor.gray.cgColor; */

        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var searchResults = [Shop]();
        
        findBarbersInCity(cities[indexPath.row]);
                        
        /* let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController;
        
        viewController.searchResults = searchResults;
        
        present(viewController, animated: true, completion: nil); */

    }
    
    func findBarbersInCity(_ city: String)
    {
        
        let ref = Database.database().reference();
        
        print(city);
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            var i = 0;
            
            if (value != nil)
            {
                for user in value!
                {
                    let currentUser = user.value as! NSDictionary;
                    
                    if ((currentUser["type"] as! Int) == 3)
                    {
                        let shop = Shop();
                        
                        shop.address = Address();
                        shop.address.fullAddress = currentUser["shopaddress"] as! String;
                        
                        if (shop.address.fullAddress.contains(city))
                        {
                            shop.username = currentUser["username"] as! String;
                            shop.firstName = currentUser["shopname"] as! String;
                            shop.rating = currentUser["rating"] as! Double;
                            shop.latitude = currentUser["latitude"] as! Double;
                            shop.longitude = currentUser["longitude"] as! Double;
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
                            self.realCities.append(shop);
                        }
                    }
                }
            }
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController;
            
            viewController.searchResults = self.realCities;
            
            self.present(viewController, animated: true, completion: nil);

        });
    }
}
