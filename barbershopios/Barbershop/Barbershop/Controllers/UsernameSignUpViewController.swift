//
//  UsernameSignUpViewController.swift
//  Barbershop
//
//  Created by user on 2017-08-23.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class UsernameSignUpViewController : UIViewController, CLLocationManagerDelegate
{
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var latitude : Double?;
    var longitude : Double?;
    var user : User?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        usernameField.backgroundColor = UIColor.clear;
        usernameField.underline();
        usernameField.isSecureTextEntry = true;
        usernameField.clearsOnBeginEditing = false;
        
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged);
        
        nextButton.roundCorners(24.0);
        nextButton.isEnabled = false;
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.2);

    }
    
    func textFieldDidChange(){
        if (!usernameField.text!.isEmpty)
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

    @IBAction func complete(sender: UIButton)
    {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription);
    }

}
