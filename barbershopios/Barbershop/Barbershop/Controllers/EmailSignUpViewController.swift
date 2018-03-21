//
//  EmailSignUpViewController.swift
//  Barbershop
//
//  Created by user on 2017-08-23.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EmailSignUpViewController : UIViewController
{
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var user : User?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let backButton = UIBarButtonItem();
        backButton.title = "";
        self.navigationItem.backBarButtonItem = backButton;

        self.navigationController?.navigationBar.tintColor = .white;

        emailAddress.backgroundColor = UIColor.clear;
        emailAddress.underline();

        emailAddress.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged);

        nextButton.roundCorners(24.0);
        nextButton.isEnabled = false;
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.2);

        emailAddress.becomeFirstResponder();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! PasswordSignUpViewController;
        
        user!.email = emailAddress.text!;
        
        viewController.user = user!;
        
    }
    func textFieldDidChange(){
        if (!emailAddress.text!.isEmpty)
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
        
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: emailAddress.text!)
        
        if(result == true)
        {
            // Segue into next
            
            activitySpinner.startAnimating();
            nextButton.setImage(nil, for: .normal);
            
            let ref = Database.database().reference();
            
            ref.child("users").queryOrdered(byChild: "email").queryStarting(atValue: emailAddress.text!).queryEnding(atValue: emailAddress.text! + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                
                self.activitySpinner.stopAnimating();
                self.nextButton.setImage(#imageLiteral(resourceName: "ic_arrow_forward"), for: .normal);
                
                if (value != nil)
                {
                    let alertController = UIAlertController(title: "Email Address Invalid", message: "Email address already exists.", preferredStyle: .alert)
                    
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil);
                    
                    alertController.addAction(okayAction);
                    
                    self.present(alertController, animated: true, completion: nil);

                }
                else
                {
                    self.performSegue(withIdentifier: "PasswordSegue", sender: self);
                }
            });
        }
        else
        {
            let alertController = UIAlertController(title: "Email Address Invalid", message: "Please enter a valid email address.", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil);
            
            alertController.addAction(okayAction);
            
            present(alertController, animated: true, completion: nil);

        }

    }
}
