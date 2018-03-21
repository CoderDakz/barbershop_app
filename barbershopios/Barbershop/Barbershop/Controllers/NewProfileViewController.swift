//
//  NewProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-16.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Cosmos

class NewProfileViewController : UIViewController
{
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var promotionsView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var bookAppointmentsView: UIView!
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var aboutUs: UITextView!
    @IBOutlet weak var aboutUsHeight: NSLayoutConstraint!
    
    var user : Shop?;
    var alertView : UIAlertController?;

    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationBar.topItem?.title = user!.firstName;
        
        if (user != nil)
        {
            ratings.rating = Double(user!.rating);
            
            if (user!.bio == "")
            {
                aboutUsHeight.constant = 0.0;
            }
            else
            {
                aboutUs.text = user!.bio;
            }
            
            let storage = Storage.storage();
            let storageRef = storage.reference(withPath: "users/" + user!.key + "/avatar.jpeg");
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if (url != nil)
                {
                    self.imageView.kf.setImage(with: url);
                }
            });
        }

        callView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callAction)));
        emailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailAction)));
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationAction)));
        galleryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(galleryAction)));
        promotionsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(promotionAction)));
        messagesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messageAction)));
        bookAppointmentsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentAction)));
    }
    
    @IBAction func backButton(sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);
    }
    
    func callAction()
    {
        if let url = URL(string: "tel://\(user!.phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func emailAction()
    {
        if let url = URL(string: "mailto://\(user!.email)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func locationAction()
    {
        let address = user!.address.fullAddress
        
        UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/?address=" + address.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)! as URL)

    }
    
    func galleryAction()
    {
        let viewController = UIStoryboard(name: "SocialMediaStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GalleryNavigation") as! GalleryNavigationController;
        
        (viewController.topViewController as! GalleryViewController).mine = false;
        (viewController.topViewController as! GalleryViewController).userKey = user!.key;
        
        self.viewDeckController?.centerViewController = viewController;
    }
    
    func promotionAction()
    {
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
    
    func messageAction()
    {
        let ref = Database.database().reference();
        
        let messageRef = ref.child("messages").childByAutoId();
        
        let messageKey = messageRef.key;
        let messageName = user!.firstName;
        
        ref.child("users").child(mainUser.key).child("messages").childByAutoId().setValue(messageKey);
        ref.child("users").child(user!.key).child("messages").childByAutoId().setValue(messageKey);
        messageRef.child("users").child(mainUser.key).setValue(mainUser.firstName);
        messageRef.child("users").child(user!.key).setValue(messageName);
        mainUser.messageList.append(messageKey);

        let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController;
        
        viewController.messageKey = messageKey;
        viewController.messageName = messageName;

        self.viewDeckController?.centerViewController = viewController;
    }
    
    func bookAppointmentAction()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookAppointmentNavigationController") as! BookAppointmentNavigationController;
        
        viewController.user = user;
        
        self.present(viewController, animated: true, completion: nil);
    }
}
