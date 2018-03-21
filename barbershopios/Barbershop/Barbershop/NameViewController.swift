//
//  NameViewController.swift
//  Barbershop
//
//  Created by user on 2017-08-23.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class NameViewController : UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var user = User();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        Configure();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! EmailSignUpViewController;
        
        user.firstName = firstName.text!;
        user.lastName = lastName.text!;
        
        viewController.user = user;
    }
    
    func Configure()
    {
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        firstName.backgroundColor = UIColor.clear;
        lastName.backgroundColor = UIColor.clear;
        
        firstName.underline();
        lastName.underline();
        
        firstName.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged);
        lastName.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged);
        
        firstName.becomeFirstResponder();
        
        nextButton.roundCorners(24.0);
        nextButton.isEnabled = false;
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.2);

    }
    
    func textFieldDidChange(){
        if (!lastName.text!.isEmpty && !firstName.text!.isEmpty)
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
    
}
