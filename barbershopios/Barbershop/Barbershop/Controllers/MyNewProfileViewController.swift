//
//  MyNewProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-20.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Firebase

class MyNewProfileViewController : UIViewController
{
    @IBOutlet weak var manageBookingsView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var analyticsView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var ratings: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        manageBookingsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(manageAction)));
        messagesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messagesAction)));
        calendarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(calendarAction)));
        analyticsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(analyticsAction)));

        let storage = Storage.storage();
        let storageRef = storage.reference(withPath: "users/" + mainUser.key + "/avatar.jpeg");
        
        storageRef.downloadURL(completion: { (url, error) in
            
            if (url != nil)
            {
                self.profileImage.kf.setImage(with: url);
            }
        });

    }
    
    @IBAction func back(sender: UIBarButtonItem)
    {
        self.viewDeckController?.open(.left, animated: true);
    }
    
    func manageAction()
    {
        if (mainUser.type == 1)
        {
            self.view.makeToast("This feature is available for Businesses only.", duration: 2.0, position: .center, title: "Under Construction", image: nil, style: nil, completion: nil)
            
        }
        else
        {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManageBookingsViewController");
            
            self.viewDeckController?.centerViewController = viewController;
        }
    }
    
    func messagesAction()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageListNavigation");
        
        self.viewDeckController?.centerViewController = viewController;
    }
    
    func calendarAction()
    {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCalendarViewController");
        
        self.viewDeckController?.centerViewController = viewController;
    }
    
    func analyticsAction()
    {
        self.view.makeToast("This feature is coming soon!", duration: 2.0, position: .center, title: "Under Construction", image: nil, style: nil, completion: nil)
    }
    
}
