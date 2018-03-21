//
//  MyProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-17.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Firebase
import Kingfisher

class MyProfileViewController : UIViewController
{
    @IBOutlet weak var myRatings: CosmosView!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var analyticsButton: UIButton!
    @IBOutlet weak var manageBookingsButton: UIButton!
    @IBOutlet weak var horizontalStackConstraint: NSLayoutConstraint!
    
    var alertView : UIAlertController?;
    
    var viewPresented = false;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        if (mainUser.type == 3)
        {
            myRatings.rating = Double((mainUser as! Shop).rating);
        }
        else if (mainUser.type == 1)
        {
            myRatings.isHidden = true;
            locationButton.isHidden = true;
            contactButton.isHidden = true;
            analyticsButton.isHidden = true;
            manageBookingsButton.isHidden = true;
            
            horizontalStackConstraint.constant = manageBookingsButton.frame.height * 2;
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(windowPressed)));
        
        let ref = Storage.storage().reference(withPath: "users/" + mainUser.key + "/avatar.jpeg");
            
        ref.downloadURL(completion: { (url, error) in
            
            print(url);
            if (url != nil)
            {
                self.imageView.kf.setImage(with: url!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (completion) in
                    mainUser.profilePic = self.imageView.image!;
                });
            }
        });
    }
    
    
    @IBAction func showCurrentLocation()
    {
        let address = (mainUser as! Shop).address.fullAddress
        print(address)
        UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/?address=" + address.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)! as URL)
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
    
    @IBAction func viewBookings(sender: UIButton)
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageBookingsViewController") as! ManageBookingsViewController;
        
        self.viewDeckController?.centerViewController = viewController;
        
        // self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func viewMessages(sender: UIButton)
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageListNavigation");
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func viewCalendar(sender: UIButton)
    {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCalendarViewController");
        
        self.viewDeckController?.centerViewController = viewController;

        // self.present(viewController, animated: true, completion: nil);

    }
    
    @IBAction func viewAnalytics(sender: UIButton)
    {
        showDialog("Under Construction", message: "This feature is coming soon!", viewController: self);
    }
    
    @IBAction func contactPressed(sender: UIButton)
    {
        let contentView = Bundle.main.loadNibNamed("ContactInfoView", owner: self, options: nil)?.first! as! ContactInfoView;
        
        let alertView = UIAlertController(title: "", message: "", preferredStyle: .alert);
        //alertView.view = contentView;
        alertView.view.bounds = contentView.frame;
        contentView.vc = alertView;
        contentView.phoneLabel.text = (mainUser as! Shop).phoneNumber;
        contentView.emailIcon.text = (mainUser as! Shop).email;
        contentView.initialize();

        let height = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.height)
        
        let weight = NSLayoutConstraint(item: alertView.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: contentView.frame.width)
        
        alertView.view.addConstraint(height);
        alertView.view.addConstraint(weight);
        
        alertView.view.addSubview(contentView);
        
        
        viewPresented = true;
        present(alertView, animated: true, completion: nil);

    }
    
    func windowPressed()
    {
        if (viewPresented)
        {
            alertView?.dismiss(animated: true, completion: nil);
            viewPresented = false;
        }
    }
    
}
