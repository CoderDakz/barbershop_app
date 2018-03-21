//
//  AuthenticationViewController.swift
//  Barbershop
//
//  Created by user on 2017-07-10.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import CoreLocation
import Firebase
import GoogleSignIn
import ViewDeck
import FacebookLogin
import FBSDKCoreKit

class AuthenticationViewController : UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var registershopButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var latitude : Double?;
    var longitude : Double?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        facebookButton.roundCorners(2.0);
        googleButton.roundCorners(2.0);
        loginButton.roundCorners(2.0);
        signupButton.roundCorners(2.0);
        registershopButton.roundCorners(2.0);
        
        loginButton.layer.borderWidth = 1;
        loginButton.layer.borderColor = UIColor.gray.cgColor;
        
        signupButton.layer.borderWidth = 1;
        signupButton.layer.borderColor = UIColor.gray.cgColor;
        
        registershopButton.layer.borderWidth = 1;
        registershopButton.layer.borderColor = UIColor.gray.cgColor;
        
        GIDSignIn.sharedInstance().delegate = self;
        GIDSignIn.sharedInstance().uiDelegate = self;
        
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    @IBAction func googleButtonPressed()
    {
        GIDSignIn.sharedInstance().signIn();
    }
    
    @IBAction func facebookButtonPressed()
    {
        // var loginManager = FBSDKLoginManager()

        var loginManager = LoginManager();
        
        loginManager.logIn([.publicProfile, .email], viewController: self, completion: { (loginManager) in
            switch (loginManager)
            {
            case .cancelled:
                break;
            case .failed(let error):
                break;
            case .success(let permissionsGranted, let permissionsDeclined, let accessToken):
                let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken);
                
                Auth.auth().signIn(with: credentials, completion: { (user, error) in
                    
                    let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email, birthday"]);
                    
                    let firebaseUser = user;
                    
                    let _ = fbRequest?.start(completionHandler: {(connection, result, error) in
                        if (error != nil) {
                            print("Error: \(error)")
                        } else {
                            let first_name = (result! as AnyObject).value(forKey: "first_name") as? String;
                            let last_name = (result! as AnyObject).value(forKey: "last_name") as? String;
                            let email = (result! as AnyObject).value(forKey: "email") as? String;
                            let birthday = (result! as AnyObject).value(forKey: "birthday") as? String;

                            let ref = Database.database().reference();
                            
                            let userKey = firebaseUser!.uid;
                            
                            ref.child("users").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
                                let value = snapshot.value as? NSDictionary;
                                
                                if (value == nil)
                                {
                                    var paramToSend = ["email" : email!, "username" : last_name! + "_" + first_name!, "birthdate" : birthday!, "fullname" : first_name! + " " + last_name!, "latitude" : self.latitude!, "longitude" : self.longitude!, "type" : 1] as [String : Any];
                                    
                                    if (self.latitude != nil)
                                    {
                                        paramToSend["latitude"] = self.latitude!
                                    }
                                    
                                    if (self.longitude != nil)
                                    {
                                        paramToSend["longitude"] = self.longitude!
                                    }
                                    
                                    mainUser = User();
                                    
                                    
                                    let defaults = UserDefaults.standard;
                                    
                                    mainUser.key = firebaseUser!.uid;
                                    mainUser.email = paramToSend["email"] as! String;
                                    mainUser.username = paramToSend["username"] as! String;
                                    mainUser.firstName = paramToSend["fullname"] as! String;
                                    mainUser.latitude = self.latitude;
                                    mainUser.longitude = self.longitude;
                                    mainUser.type = 1;
                                    
                                    // Push all of our set parameters to the server
                                    ref.child("users").child(user!.uid).setValue(paramToSend);
                                    
                                    defaults.setValue(user!.uid, forKey: "user_id");
                                    defaults.setValue( false, forKey: "registered");
                                    
                                    if (defaults.synchronize() == false)
                                    {
                                        print("Didnt save");
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                                        {
                                            
                                            let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewProfileViewController");
                                            
                                            let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
                                            
                                            let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                                            
                                            self.present(sideController, animated: false, completion: nil);
                                    })
                                    
                                }
                                else
                                {
                                    mainUser = User();
                                    
                                    mainUser.username = value!["username"] as! String;
                                    mainUser.email = value!["email"] as! String;
                                    mainUser.key = snapshot.key;
                                    mainUser.type = value!["type"] as! Int;
                                    
                                    if (value!["latitude"] != nil && value!["longitude"] != nil)
                                    {
                                        mainUser.latitude = value!["latitude"] as! Double;
                                        mainUser.longitude = value!["longitude"] as! Double;
                                    }
                                    
                                    let messagesShot = value!["messages"] as? NSDictionary;
                                    
                                    if (messagesShot != nil)
                                    {
                                        for messages in (messagesShot!.allValues as! [String])
                                        {
                                            mainUser.messages[messages] = [Message]();
                                            mainUser.messageList.append(messages);
                                        }
                                    }
                                    
                                    let defaults = UserDefaults.standard;
                                    defaults.setValue(user!.uid, forKey: "user_id");
                                    defaults.setValue( false, forKey: "registered");
                                    
                                    if (defaults.synchronize() == false)
                                    {
                                        print("Didnt save");
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                                        {
                                            
                                            let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewProfileViewController");
                                            
                                            let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
                                            
                                            let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                                            
                                            self.present(sideController, animated: false, completion: nil);
                                    })
                                    
                                    
                                }
                            });

                            
                        }
                    });
                    
                });
                break;
                
            }
        });
        
    }
    
    @IBAction func goLogin()
    {
        // let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "SignUpNewNavigationController")
        
        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "MainMenu")
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func goSignup()
    {
        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "SignUpNewNavigationController") as! UINavigationController;
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func goRegistershop()
    {
        // let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "BusinessAccountCreation")
        
        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "SignUpNavigationController") as! UINavigationController;
        
        (viewController.topViewController! as! SignUpUserViewController).isShop = true;
        
        self.present(viewController, animated: true, completion: nil);
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error: \(error.localizedDescription)");
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        let googleUser = user;
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)");
                return
            }
            
            let ref = Database.database().reference();
            
            let userKey = user!.uid;
            
            ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary;
                
                if (value == nil)
                {
                    var paramToSend = ["email" : googleUser!.profile!.email!, "username" : googleUser!.profile.familyName + "_" + googleUser!.profile.givenName, "birthdate" : "", "fullname" : googleUser!.profile.givenName + " " + googleUser!.profile.familyName, "type" : 1] as [String : Any];
                    
                    if let latitude = self.latitude
                    {
                        paramToSend["latitude"] = latitude;
                    }
                    
                    if let longitude = self.longitude
                    {
                        paramToSend["longitude"] = longitude;
                    }

                    mainUser = User();
                
                    let defaults = UserDefaults.standard;
                    
                    mainUser.key = user!.uid;
                    mainUser.email = paramToSend["email"] as! String;
                    mainUser.username = paramToSend["username"] as! String;
                    mainUser.firstName = paramToSend["fullname"] as! String;
                    mainUser.latitude = self.latitude;
                    mainUser.longitude = self.longitude;
                    mainUser.type = 1;
                    
                    // Push all of our set parameters to the server
                    ref.child("users").child(user!.uid).setValue(paramToSend);
                    
                    defaults.setValue(user!.uid, forKey: "user_id");
                    defaults.setValue( false, forKey: "registered");
                    
                    if (defaults.synchronize() == false)
                    {
                        print("Didnt save");
                    }
                    
                    DispatchQueue.main.async {
                        self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                        {
                            
                            let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewProfileViewController");
                            
                            let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
                            
                            let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                            
                            self.present(sideController, animated: false, completion: nil);
                    })
                    
                }
                else
                {
                    mainUser = User();
                    
                    mainUser.username = value!["username"] as! String;
                    mainUser.firstName = value!["fullname"] as! String;
                    mainUser.email = value!["email"] as! String;
                    mainUser.key = snapshot.key;
                    mainUser.type = value!["type"] as! Int;
                    
                    if (value!["latitude"] != nil && value!["longitude"] != nil)
                    {
                        mainUser.latitude = value!["latitude"] as! Double;
                        mainUser.longitude = value!["longitude"] as! Double;
                    }
                    
                    let messagesShot = value!["messages"] as? NSDictionary;
                    
                    if (messagesShot != nil)
                    {
                        for messages in (messagesShot!.allValues as! [String])
                        {
                            mainUser.messages[messages] = [Message]();
                            mainUser.messageList.append(messages);
                        }
                    }
                    
                    let defaults = UserDefaults.standard;
                    defaults.setValue(user!.uid, forKey: "user_id");
                    defaults.setValue( false, forKey: "registered");
                    
                    if (defaults.synchronize() == false)
                    {
                        print("Didnt save");
                    }
                    
                    DispatchQueue.main.async {
                        self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                        {
                            
                            let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewProfileViewController");
                            
                            let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
                            
                            let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                            
                            self.present(sideController, animated: false, completion: nil);
                    })


                }
            });
        });
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription);
    }
    
    
}
