//
//  SideMenuNewController.swift
//  Barbershop
//
//  Created by user on 2017-09-17.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideMenuNewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    let menuPictures = [#imageLiteral(resourceName: "ic_profile"), #imageLiteral(resourceName: "ic_calendar"), #imageLiteral(resourceName: "ic_search"), #imageLiteral(resourceName: "ic_gallery"), #imageLiteral(resourceName: "ic_bookings"), #imageLiteral(resourceName: "ic_messages"), #imageLiteral(resourceName: "ic_promotions"), #imageLiteral(resourceName: "ic_settings")];
    let menuOptions = ["Profile", "Calendar", "Search", "Gallery", "My Bookings", "Messages", "Promotions", "Logout"];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.tableFooterView = UIView();
        tableView.delegate = self;
        tableView.dataSource = self;
        
        userName.text = mainUser.firstName;
        profilePicture.roundCorners(32);

        let storage = Storage.storage().reference();
        
        storage.child("users").child(mainUser.key).child("avatar.jpeg").downloadURL(completion: { (url, error) in
    
            if (url != nil)
            {
                self.profilePicture.kf.setImage(with: url!);
            }
            else
            {
                self.profilePicture.image = #imageLiteral(resourceName: "UserPlaceholderimg");
            }
        });
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell;
        
        cell.icon.image = menuPictures[indexPath.row];
        cell.option.text = menuOptions[indexPath.row];
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false);
        
        if (indexPath.row == 0)
        {
            let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewerProfileViewController");
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true);
        }
        else if (indexPath.row == 1)
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCalendarViewController");
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true);
            
            // self.present(viewController, animated: true, completion: nil);
        }
        else if (indexPath.row == 2)
        {
            /* viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController");
             
             self.present(viewController, animated: true, completion: nil); */
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController");
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true);
        }
        else if (indexPath.row == 3)
        {
            let viewController = UIStoryboard(name: "SocialMediaStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GalleryNavigation") as! UINavigationController;
            
            (viewController.topViewController as! GalleryViewController).mine = true;
            (viewController.topViewController as! GalleryViewController).userKey = mainUser.key;
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true);
        }
        else if (indexPath.row == 4)
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageBookingsViewController");
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true);
            
            /* if (mainUser.type == 1)
             {
             self.view.makeToast("This feature is available for Businesses only.", duration: 2.0, position: .center, title: "Under Construction", image: nil, style: nil, completion: nil)
             
             }
             else
             {
             let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageBookingsViewController");
             
             self.viewDeckController?.centerViewController = viewController;
             self.viewDeckController?.closeSide(true);
             } */
        }
        else if (indexPath.row == 5)
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageListNavigation");
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true);
        }
        else if (indexPath.row == 6)
        {
            let ref = Database.database().reference();
            
            if (mainUser.type == 3)
            {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PromotionsNavigationController") as! UINavigationController;
                
                (viewController.topViewController as! PromotionsViewController).listOfPromotions = (mainUser as! Shop).promotions;
                (viewController.topViewController as! PromotionsViewController).mine = true;
                
                self.viewDeckController?.centerViewController = viewController;
                self.viewDeckController?.closeSide(true);
                
            }
            else
            {
                ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    var promos = [Promotion]();
                    
                    var i = 0;
                    
                    if (value != nil)
                    {
                        for user in value!
                        {
                            let currUser = user.value as! NSDictionary;
                            
                            let promotions = currUser["promotions"] as? NSDictionary;
                            
                            if (promotions != nil)
                            {
                                for promotion in promotions!
                                {
                                    print(promotion);
                                    let currPromotion = promotion.value as! NSDictionary;
                                    
                                    let bio = currPromotion["promodescription"] as! String;
                                    
                                    let newPromotion = Promotion();
                                    
                                    newPromotion.bio = bio;
                                    newPromotion.promoKey = promotion.key as! String
                                    newPromotion.shopKey = user.key as! String;
                                    newPromotion.pk = i;
                                    
                                    i += 1;
                                    promos.append(newPromotion);
                                    
                                }
                            }
                        }
                    }
                    
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PromotionsNavigationController") as! UINavigationController;
                    
                    (viewController.topViewController as! PromotionsViewController).listOfPromotions = promos;
                    (viewController.topViewController as! PromotionsViewController).mine = true;
                    
                    self.viewDeckController?.centerViewController = viewController;
                    self.viewDeckController?.closeSide(true);
                    
                });
            }
        }
        else if (indexPath.row == 7)
        {
            /* let viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigationController");
            
            self.viewDeckController?.centerViewController = viewController;
            self.viewDeckController?.closeSide(true); */
            
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
    
    
}
