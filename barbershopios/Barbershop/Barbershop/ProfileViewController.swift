//
//  ProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-01.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Firebase

class ProfileViewController : UIViewController
{

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    
    var user : Shop?;
    var alertView : UIAlertController?;
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        customNavigationItem.title = user!.firstName;
        
        if (user != nil)
        {
            ratings.rating = Double(user!.rating);
            
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + user!.key + "/avatar.jpeg");
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    self.imageView.kf.setImage(with: url);
                }
            });
        }
        
        let ref = Database.database().reference();
        
        ref.child("users").child(user!.key).child("barbers").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary;
            
            if (value != nil)
            {
                self.user!.barbers = [Barber]();
                
                for barberKey in (value!.allValues as! [String])
                {
                    var barber = Barber();
                    
                    barber.key = barberKey;
                    
                    self.user!.barbers.append(barber);
                }
            }
        });
        
        imageView.roundCorners(2);
        
        ratings.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewRatings)));
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        locationButton.roundCorners(28);
        contactButton.roundCorners(28);
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BookingSegue")
        {
            let viewController = segue.destination as! BookAppointmentNavigationController;
            
            viewController.user = user;
        }
    }
    
    func viewRatings()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RatingsViewController") as! RatingsViewController;
        
        viewController.shopKey = user!.key;
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    func windowPressed()
    {
        if (alertView?.isFirstResponder)!
        {
            alertView?.resignFirstResponder();
        }
    }
    
    @IBAction func contactPressed(sender: UIButton)
    {
        let contentView = Bundle.main.loadNibNamed("ContactInfoView", owner: self, options: nil)?.first! as! ContactInfoView;
        
        let alertView = UIAlertController(title: "", message: "", preferredStyle: .alert);
        //alertView.view = contentView;
        alertView.view.bounds = contentView.frame;
        contentView.vc = alertView;
        contentView.phoneLabel.text = user!.phoneNumber;
        contentView.emailIcon.text = user!.email;
        contentView.initialize();
        
        let height = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.height)
        
        let weight = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.width)
        
        alertView.view.addConstraint(height);
        alertView.view.addConstraint(weight);
        
        alertView.view.addSubview(contentView);
      
        // viewPresented = true;
        present(alertView, animated: true, completion: nil);
        
    }
    
    @IBAction func showCurrentLocation()
    {
        let address = user!.address.fullAddress
        
        UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/?address=" + address.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)! as URL)
    }
    
    @IBAction func viewAboutUs(_ sender: Any)
    {
        let contentView = Bundle.main.loadNibNamed("AboutUsView", owner: self, options: nil)?.first! as! AboutUsView;
        
        let alertView = UIAlertController(title: "", message: "", preferredStyle: .alert);
        //alertView.view = contentView;
        alertView.view.bounds = contentView.frame;
        contentView.vc = alertView;
        contentView.aboutUs.text = user!.bio;
        
        let height = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.height)
        
        let weight = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.width)
        
        alertView.view.addConstraint(height);
        alertView.view.addConstraint(weight);
        
        alertView.view.addSubview(contentView);
        
        // viewPresented = true;
        present(alertView, animated: true, completion: nil);

    }
 
    @IBAction func viewPhotos(_ sender: Any) {
        
        let viewController = UIStoryboard(name: "SocialMediaStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GalleryNavigation") as! GalleryNavigationController;
        
        (viewController.topViewController as! GalleryViewController).mine = false;
        (viewController.topViewController as! GalleryViewController).userKey = user!.key;

        self.present(viewController, animated: true, completion: nil);

    }
    
    @IBAction func viewNewsFeed(_ sender: Any) {
        let ref = Database.database().reference();
        
        ref.child("users").child(user!.key).child("promotions").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var promos = [Promotion]();
            
            var i = 0;
            
            if (value != nil)
            {
                for promotion in value!
                {
                    let bio = promotion.value as! String;
                    
                    let newPromotion = Promotion();
                    
                    newPromotion.bio = bio;
                    newPromotion.promoKey = promotion.key as! String
                    newPromotion.shopKey = self.user!.key;
                    newPromotion.pk = i;
                    
                    i += 1;
                    promos.append(newPromotion);
                }
            }
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PromotionsNavigationController") as! UINavigationController;
            
            (viewController.topViewController as! PromotionsViewController).listOfPromotions = promos;
            (viewController.topViewController as! PromotionsViewController).mine = false;

            self.present(viewController, animated: true, completion: nil);
            
        });

    }
    
    func drawerLayoutDidOpen() {
        
    }
}
