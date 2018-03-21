//
//  MyNewerProfileViewController.swift
//  Barbershop
//
//  Created by user on 2017-09-06.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MyNewerProfileViewController: UIViewController
{
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let names = mainUser.firstName.components(separatedBy: " ");
        
        firstNameTextField.text = names[0];
        lastNameTextField.text = names[1];
        emailTextField.text = mainUser.email;
        usernameTextField.text = mainUser.username;
        
        let storageRef = Storage.storage().reference(withPath: "users/" + mainUser.key + "/avatar.jpeg");
        
        storageRef.downloadURL(completion: { (url, error) in
            
            if (url != nil)
            {
                self.profilePicture.kf.setImage(with: url);
            }
        });

    }
    
    @IBAction func menu()
    {
        self.viewDeckController?.open(.left, animated: true);
        // dismiss(animated: true, completion: nil);
    }
    
    @IBAction func settings()
    {
        let viewController = UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigationController");
        
        self.viewDeckController?.centerViewController = viewController;
    }
}
