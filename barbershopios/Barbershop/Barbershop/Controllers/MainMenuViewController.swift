//
//  MainMenuViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-06.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import Firebase
import ViewDeck

class MainMenuViewController : UIViewController
{
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var bookingsView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var promotionsView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    var viewController : UIViewController!;
    var menuSelections = [UITapGestureRecognizer]();
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        /*if(ref.child("users").child(mainUser.key).child("appointments").child(shortDateFormatter.string(from: appointment!.date)).child("appCompleted") == "completed"
         {
         let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RatingsViewController");
         
         self.present(viewController, animated: true, completion: nil);
         
         }
         
         */
        
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
        uploadView.addGestureRecognizer(menuSelections[3]);
        bookingsView.addGestureRecognizer(menuSelections[4]);
        messagesView.addGestureRecognizer(menuSelections[5]);
        promotionsView.addGestureRecognizer(menuSelections[6]);
        settingsView.addGestureRecognizer(menuSelections[7]);
        
        self.toastStyling()
        
        checkIfReviewsNeedToBeCompleted();

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        uploadProfilePic();
    }
    
    func profileClick()
    {
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyProfileViewController");
        
        // viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "ExampleViewController");
        self.present(viewController, animated: true, completion: nil);
    }
    
    func calendarClick()
    {
        // viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCalendarViewController");
        let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController;
        
        viewController.user = (mainUser as! Shop);
        
        let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
        
        let viewDeck = IIViewDeckController(center: viewController, leftViewController: nviewController);
        
        self.present(viewDeck, animated: true, completion: nil);

        // self.present(viewController, animated: true, completion: nil);
    }
    
    func searchClick()
    {
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController");
        
        let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
        
        let viewDeck = IIViewDeckController(center: viewController, leftViewController: nviewController);
        
        self.present(viewDeck, animated: true, completion: nil);
    }
    
    func uploadClick()
    {
        let viewController = UIStoryboard(name: "SocialMediaStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GalleryNavigation") as! UINavigationController;
        
        (viewController.topViewController as! GalleryViewController).mine = true;
        (viewController.topViewController as! GalleryViewController).userKey = mainUser.key;
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    func bookingsClick()
    {
        if (mainUser.type == 1)
        {
            self.view.makeToast("This feature is available for Businesses only.", duration: 2.0, position: .center, title: "Under Construction", image: nil, style: nil, completion: nil)

        }
        else
        {
            viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageBookingsViewController");
            
            self.present(viewController, animated: true, completion: nil);
        }
    }
    
    func messagesClick()
    {
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageListNavigation");
        
        self.present(viewController, animated: true, completion: nil);

        // self.view.makeToast("This feature is coming soon", duration: 2.0, position: .center, title: "Under Construction", image: nil, style: nil, completion: nil)
        
    }
    
    func promotionsClick()
    {
        let ref = Database.database().reference();
        
        if (mainUser.type == 3)
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PromotionsNavigationController") as! UINavigationController;
            
            (viewController.topViewController as! PromotionsViewController).listOfPromotions = (mainUser as! Shop).promotions;
            (viewController.topViewController as! PromotionsViewController).mine = true;
            
            self.present(viewController, animated: true, completion: nil);
            
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
                                let bio = promotion.value as! String;
                                
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
                (viewController.topViewController as! PromotionsViewController).mine = false;
                
                self.present(viewController, animated: true, completion: nil);

            });
        }
        
        
        
        // });
        
    }
    
    func settingsClick()
    {
        viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigationController");
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    func uploadProfilePic()
    {
        let defaults = UserDefaults.standard;
        let registered = defaults.bool(forKey: "registered");
        
        print(registered);
        
        if (registered == false)
        {
            let contentView = Bundle.main.loadNibNamed("UploadProfile", owner: self, options: nil)?.first! as! UploadProfileView;
            
            let alertView = UIAlertController(title: "", message: "", preferredStyle: .alert);
            //alertView.view = contentView;
            alertView.view.bounds = contentView.frame;
            contentView.vc = alertView;
            contentView.makeLayoutChangesToView();
            
            let height = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.height)
            
            let weight = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.width)
            
            alertView.view.addConstraint(height);
            alertView.view.addConstraint(weight);
            
            alertView.view.addSubview(contentView);
            
            present(alertView, animated: true, completion: nil);
        }
    }
    
    func checkIfReviewsNeedToBeCompleted()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(mainUser.key).child("mandatoryReviews").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            if (value != nil)
            {
                for review in (value!.allValues as! [String])
                {
                    let shopKey = review;
                    
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RatingsViewController") as! RatingsViewController;
                    
                    viewController.shopKey = shopKey;
                    
                    self.present(viewController, animated: true, completion: nil);

                }
            }
        });
    }
}
