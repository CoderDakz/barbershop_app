//
//  Extensions.swift
//  Barbershop
//
//  Created by user on 2017-08-23.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class PasswordSignUpViewController : UIViewController
{
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var user : User?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        self.navigationController?.navigationBar.tintColor = .white;
        
        passwordField.backgroundColor = UIColor.clear;
        passwordField.underline();
        passwordField.isSecureTextEntry = true;
        passwordField.clearsOnBeginEditing = false;
        
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged);
        
        nextButton.roundCorners(24.0);
        nextButton.isEnabled = false;
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.2);
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! UsernameSignUpViewController;
        
        user!.password = passwordField.text!;
        
        viewController.user = user!;
    }
    
    func textFieldDidChange(){
        if (!passwordField.text!.isEmpty)
        {
            nextButton.isEnabled = true;
            nextButton.backgroundColor = UIColor.white.withAlphaComponent(1.0);
        }
        else
        {
            nextButton.isEnabled = false;
            nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.2);
            
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        if (passwordField.text!.characters.count < 8)
        {
            
        }
        
        self.performSegue(withIdentifier: "UsernameSegue", sender: self);
    }
    
    @IBAction func showButtonPressed(_ sender: UIButton) {
        if (sender.titleLabel!.text! == "Show")
        {
            sender.setTitle("Hide", for: .normal);
            passwordField.isSecureTextEntry = false;
        }
        else
        {
            sender.setTitle("Show", for: .normal);
            passwordField.isSecureTextEntry = true;
            passwordField.clearsOnBeginEditing = false;

        }
    }
}
