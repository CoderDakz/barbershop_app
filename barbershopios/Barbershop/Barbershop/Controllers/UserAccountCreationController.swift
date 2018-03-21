//
//  ViewController.swift
//  BarbershopsApp
//
//  Created by user on 2017-05-26.
//  Copyright © 2017 Codewater. All rights reserved.
//

import UIKit
import Toast_Swift
import CoreLocation
import Firebase

class UserAccountCreation: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate
{
    
    @IBOutlet var firstNameAccCreationTextField : UITextField!
    @IBOutlet var lastNameAccCreationTextField :  UITextField!
    @IBOutlet var emailAccCreationTextField : UITextField!
    @IBOutlet var passwordAccCreationTextField : UITextField!
    @IBOutlet var usernameAccCreationTextField : UITextField!
    @IBOutlet var bdayAccCreationPicker : UIDatePicker!
    @IBOutlet weak var barberSwitch: UISwitch!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet var bdayOuterView: UIView!
    
    
    @IBAction func goBack()
    {
        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "ExampleViewController");
        
        self.present(viewController, animated: true, completion: nil);

    }
    
    
    @IBOutlet var createButton : UIButton!
    
    let locationManager = CLLocationManager()
    
    var latitude : Double?;
    var longitude : Double?;

    @IBAction func register_Button (_ sender: Any){
    
        // Grab all variables the user has inputted, and register them
        let username = self.usernameAccCreationTextField.text
        let password = self.passwordAccCreationTextField.text
        let email = self.emailAccCreationTextField.text
        let firstname = self.firstNameAccCreationTextField.text
        let lastname = self.lastNameAccCreationTextField.text
        
        let fullname = firstname! + lastname!
        
        let dateFormatting = DateFormatter()
        dateFormatting.dateFormat = "yyyy-MM-dd"
        let chosenDate = dateFormatting.string(from: bdayAccCreationPicker.date)
        
        if (username == "" || password == "" || email == "" || firstname == "" || lastname == "")
        {
            return
        }
        
        DoRegister(username!, password!, email!, fullname, chosenDate, latitude!, longitude!);
    }
    
    func DoRegister(_ user: String, _ psw: String, _ email: String, _ fullname: String, _ birthdate: String, _ latitude: Double, _ longitude: Double) {
        
        // Initialize connection with server
        let url = URL(string: "http://shop.thedmproject.info/register.php");
        let session = URLSession.shared;
        
        let request = NSMutableURLRequest(url: url!);
        
        request.httpMethod = "POST";
        
        // Create the parameters to send to server. paramToSend sends to Daniel's server, paramToSend2 sends to Firebase.
        var paramToSend = "email=" + email + "&username=" + user + "&password=" + psw + "&birthdate=" + birthdate + "&fullname=" + fullname + "&type=" + "1";
        
        var paramToSend2 = ["email" : email, "username" : user, "birthdate" : birthdate, "fullname" : fullname, "latitude" : latitude, "longitude" : longitude, "type" : barberSwitch.isOn ? 2 : 1] as [String : Any];
        
        // If this is a barber, send a new empty schedule to the server
        if ((paramToSend2["type"] as! Int) == 2)
        {
            let time = TimeSlot();
            
            paramToSend2["schedule"] = time.scheduleToString();
        }
        
        Auth.auth().createUser(withEmail: email, password: psw, completion: { (user, error) in
            let ref = Database.database().reference();
            
            if (user == nil)
            {
                print(error?.localizedDescription);
            }
            
            if (self.barberSwitch.isOn == true)
            {
                mainUser = Barber();
                (mainUser as! Barber).schedule.stringToSchedule(string: paramToSend2["schedule"] as! String);
            }
            else
            {
                mainUser = User();
            }
            
            let defaults = UserDefaults.standard;
            
            mainUser.key = user!.uid;
            mainUser.email = email;
            mainUser.username = self.usernameAccCreationTextField.text!;
            mainUser.firstName = fullname;
            mainUser.latitude = latitude;
            mainUser.longitude = longitude;
            mainUser.type = self.barberSwitch.isOn ? 2 : 1;
            
            // Push all of our set parameters to the server
            ref.child("users").child(user!.uid).setValue(paramToSend2);
            
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
                    
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
                    
                    self.present(viewController, animated: true, completion: nil);
            })

            
        });
        
       /*  // Also send the current latitude and longitude
        paramToSend += "&latitude=" + String(latitude) + "&longitude=" + String(longitude);
        
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        // Send data to server
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data else
            {
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
                
            catch
            {
                return
            }
            
            guard let server_response = json as? NSDictionary else
            {
                return
            }
            
            
            // dump (server_response);
            print(server_response["success"]!);
            
            let data_block : NSString
            
            if(server_response["success"] is NSNumber)
            {
                data_block = (server_response["success"] as! NSNumber).stringValue as NSString
            }
            else
            {
                data_block = (server_response["success"] as! NSString)
            }
            
            
            if data_block != "0"
            {
                // Create user inside Firebase
                Auth.auth().createUser(withEmail: email, password: psw, completion: { (user, error) in
                    let ref = Database.database().reference();

                    if (user == nil)
                    {
                        print(error?.localizedDescription);
                    }
                    
                    if (self.barberSwitch.isOn == true)
                    {
                        mainUser = Barber();
                        (mainUser as! Barber).schedule.stringToSchedule(string: paramToSend2["schedule"] as! String);
                    }
                    else
                    {
                        mainUser = User();
                    }
                    
                    mainUser.key = user!.uid;
                    mainUser.email = email;
                    mainUser.username = self.usernameAccCreationTextField.text!;
                    mainUser.firstName = fullname;
                    mainUser.latitude = latitude;
                    mainUser.longitude = longitude;
                    mainUser.type = self.barberSwitch.isOn ? 2 : 1;

                    // Push all of our set parameters to the server
                    ref.child("users").child(user!.uid).setValue(paramToSend2);
                    
                    // Save the current user ID
                    let defaults = UserDefaults.standard;
                    
                    defaults.setValue(user!.uid, forKey: "user_id");
                    
                });
                
                // Execute the Register Done function
                DispatchQueue.main.async (
                    execute:self.RegisterDone
                )
            }
            else{
                // Error: Account already exists.
                DispatchQueue.main.async {
                    self.view.makeToast("Account already exists...", duration: 2.0, position: .center)
                }
            }

        })
        
        task.resume(); */
    }
    
    
    func RegisterDone()
    {
        //LOGIN TO NEWLY REGISTERED ACC AND SEGUE INTO MAIN MENU PAGE
        
        let username = usernameAccCreationTextField.text
        let password = passwordAccCreationTextField.text
        
        let url = URL(string: "http://shop.thedmproject.info/login.php");
        let session = URLSession.shared;
        
        let request = NSMutableURLRequest(url: url!);
        
        request.httpMethod = "POST";
        
        let paramToSend2 = "login=" + username! + "&password=" + password!;
        
        request.httpBody = paramToSend2.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data else
            {
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
                
            catch
            {
                return
            }
            
            guard let server_response = json as? NSDictionary else
            {
                return
            }
            
            
            // dump (server_response);
            print(server_response);
            
            let data_block : NSString
            
            if(server_response["success"] is NSNumber)
            {
                data_block = (server_response["success"] as! NSNumber).stringValue as NSString
            }
            else
            {
                data_block = (server_response["success"] as! NSString)
            }
            
            
            if data_block != "0"
            {

                let defaults = UserDefaults.standard;
                    
                // defaults.setValue( data_block , forKey: "user_id");
                defaults.setValue( server_response["type"] , forKey: "acc_type")    
                defaults.setValue( false, forKey: "registered");
                    
                defaults.setValue(username, forKey: "user_name");
                defaults.setValue(password, forKey: "user_pass");
                    
                if (defaults.synchronize() == false)
                {
                    print("Didnt save");
                }
                    
                DispatchQueue.main.async {
                    self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
                }
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                {
                            
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
                            
                    self.present(viewController, animated: true, completion: nil);
                })

            }
            
            /*if let data_block = server_response["data"] as? NSDictionary
             {
             print("\nFirst if statement");
             
             if let session_data = data_block["session"] as? String
             {
             print("\nSecond if statement\n")
             
             let preferences = UserDefaults.standard
             preferences.set(session_data, forKey: "session")
             
             DispatchQueue.main.async (
             execute:self.LoginDone
             )
             print("\nMade it through entire doLogin function.\n");
             }
             }*/
        })
        
        task.resume();

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription);
    }
    
   //AUTO WRITTEN CODE AS PER EVERY NEW FILE
     override func viewDidLoad() {
        super.viewDidLoad()
        
        //calling function to hide keyboard when tapped away from textfields.
        self.hideKeyboardWhenTappedAround() 
        
        bdayAccCreationPicker?.datePickerMode = .date;
        bdayOuterView?.layer.cornerRadius = 5;
        bdayOuterView?.layer.masksToBounds = true;
        
        self.toastStyling()
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}
    
    
    

    
    
    
    



