//
//  SideMenuController.swift
//  Barbershop
//
//  Created by user on 2017-07-14.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideMenuController : UIViewController
{
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var uploadsView: UIView!
    @IBOutlet weak var manageBookingsView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var promotionsView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    var menuSelections = [UITapGestureRecognizer]();

    override func viewDidLoad() {
        super.viewDidLoad();
            
        nameLabel.text = mainUser.firstName;
        
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(profileClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(calendarClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(searchClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(uploadClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(bookingsClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(messagesClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(promotionsClick)));
        menuSelections.append(UITapGestureRecognizer(target: self, action: #selector(settingsClick)));
        
        profileView.addGestureRecognizer(menuSelections[0]);
        calendarView.addGestureRecognizer(menuSelections[1]);
        searchView.addGestureRecognizer(menuSelections[2]);
        uploadsView.addGestureRecognizer(menuSelections[3]);
        manageBookingsView.addGestureRecognizer(menuSelections[4]);
        messagesView.addGestureRecognizer(menuSelections[5]);
        promotionsView.addGestureRecognizer(menuSelections[6]);
        settingsView.addGestureRecognizer(menuSelections[7]);
    }
    
    func profileClick()
    {
        let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewerProfileViewController");

        self.viewDeckController?.centerViewController = viewController;
        self.viewDeckController?.closeSide(true);
    }
    
    func calendarClick()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCalendarViewController");

        self.viewDeckController?.centerViewController = viewController;
        self.viewDeckController?.closeSide(true);

        // self.present(viewController, animated: true, completion: nil);
    }
    
    func searchClick()
    {
        /* viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController");
        
        self.present(viewController, animated: true, completion: nil); */
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController");
        
        self.viewDeckController?.centerViewController = viewController;
        self.viewDeckController?.closeSide(true);
    }
    
    func uploadClick()
    {
        let viewController = UIStoryboard(name: "SocialMediaStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GalleryNavigation") as! UINavigationController;
        
        (viewController.topViewController as! GalleryViewController).mine = true;
        (viewController.topViewController as! GalleryViewController).userKey = mainUser.key;
        
        self.viewDeckController?.centerViewController = viewController;
        self.viewDeckController?.closeSide(true);
    }
    
    func bookingsClick()
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
    
    func messagesClick()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageListNavigation");
        
        self.viewDeckController?.centerViewController = viewController;
        self.viewDeckController?.closeSide(true);
    }
    
    func promotionsClick()
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
    
    func settingsClick()
    {
        let viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigationController");
        
        self.viewDeckController?.centerViewController = viewController;
        self.viewDeckController?.closeSide(true);
    }

}
