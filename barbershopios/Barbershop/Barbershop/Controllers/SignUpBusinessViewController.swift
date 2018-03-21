//
//  SignUpBusinessViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-24.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ViewDeck

class SignUpBusinessViewController : UIViewController
{
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var shopAddress: UITextField!
    @IBOutlet weak var shopPhoneNumber: UITextField!
    @IBOutlet weak var aboutUs: UITextView!
    
    var shop : Shop?;
    var latitude : Double?;
    var longitude : Double?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
    }
    
    @IBAction func signUp(sender: UIBarButtonItem)
    {
        let testURL = "https://maps.google.com/maps/api/geocode/json?address=" + shopAddress.text!.replacingOccurrences(of: " ", with: "%20");
        
        guard let myURL = URL(string: testURL) else {
            print(testURL);
            return;
        }
        
        do
        {
            let myURLString = try String(contentsOf: myURL)
            
            if (!myURLString.contains("ZERO_RESULTS"))
            {
                let position = getCoordinateFromJSON(myURLString);
                
                let latitude = position?.latitude;
                let longitude = position?.longitude;
                
                let paramToSend = ["email" : shop!.email, "username" : shop!.username, "birthdate" : "", "fullname" : shop!.firstName + " " + shop!.lastName, "shopname" : shopName.text!, "shopaddress" : shopAddress.text!, "latitude" : latitude!, "longitude" : longitude!, "type" : 3, "rating" : 0.0, "ratingAmount" : 0, "phonenumber" : shopPhoneNumber.text!, "aboutus" : aboutUs.text!] as [String : Any];
                
                Auth.auth().createUser(withEmail: shop!.email, password: shop!.password, completion: { (user, error) in
                    let ref = Database.database().reference();
                    
                    let defaults = UserDefaults.standard;
                    
                    mainUser = Shop();
                    
                    mainUser.key = user!.uid;
                    mainUser.email = self.shop!.email;
                    mainUser.username = self.shop!.username;
                    mainUser.firstName = self.shop!.firstName + " " + self.shop!.lastName;
                    mainUser.latitude = latitude;
                    mainUser.longitude = longitude;
                    mainUser.type = 3;
                    (mainUser as! Shop).rating = 0.0;
                    (mainUser as! Shop).phoneNumber = self.shopPhoneNumber.text!;
                    (mainUser as! Shop).address = Address();
                    (mainUser as! Shop).address.fullAddress = self.shopAddress.text!;
                    
                    ref.child("users").child(user!.uid).setValue(paramToSend);
                    
                    defaults.setValue(user!.uid, forKey: "user_id");
                    
                    defaults.setValue( false, forKey: "registered");
                    
                    if (defaults.synchronize() == false)
                    {
                        print("Didnt save");
                    }
                    
                    DispatchQueue.main.async {
                        self.view.makeToast("Successfully created account!", duration: 2.0, position: .center)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                        {
                            
                            let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewerProfileViewController");
                            
                            let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController");
                            
                            let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                            
                            self.present(sideController, animated: false, completion: nil);
                    })
                    
                });
                
            }
        }
        catch {
            self.view.makeToast("Invalid address! Please check your address and try again.", duration: 2.0, position: .center);
        }

    }
    
}
