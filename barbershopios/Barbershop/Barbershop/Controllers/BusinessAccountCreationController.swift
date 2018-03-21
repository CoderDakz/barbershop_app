//
//  BusinessAccountCreation.swift
//  BarbershopsApp
//
//  Created by user on 2017-06-13.
//  Copyright © 2017 Codewater. All rights reserved.
//

import UIKit
import Toast_Swift
import Firebase
import CoreLocation

class BusinessAccountCreation: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UITextViewDelegate
{
    
    @IBOutlet var firstNameAccCreationTextField : UITextField!
    @IBOutlet var lastNameAccCreationTextField :  UITextField!
    @IBOutlet var emailAccCreationTextField : UITextField!
    @IBOutlet var passwordAccCreationTextField : UITextField!
    @IBOutlet var usernameAccCreationTextField : UITextField!
    @IBOutlet var shopNameAccCreationTextField : UITextField!
    @IBOutlet var shopAddressAccCreationTextField : UITextField!
    @IBOutlet var bdayAccCreationPicker : UIDatePicker!
    @IBOutlet weak var phoneNumberCreationTextField: UITextField!
    @IBOutlet weak var aboutUsTextView: UITextView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet var bdayOuterView : UIView!
    
    @IBAction func goBack()
    {
        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "ExampleViewController");
        
        self.present(viewController, animated: true, completion: nil);

    }
    
    
    @IBOutlet var createButton : UIButton!
    
    let locationManager = CLLocationManager()
    var latitude: Double?;
    var longitude: Double?;

    @IBAction func register_Button (_ sender: Any){
        
        
        let username = usernameAccCreationTextField.text
        let password = passwordAccCreationTextField.text
        let email = emailAccCreationTextField.text
        let firstname = firstNameAccCreationTextField.text
        let lastname = lastNameAccCreationTextField.text
        let shopname = shopNameAccCreationTextField.text
        let shopaddress = shopAddressAccCreationTextField.text
        
        let fullname = firstname! + lastname!
        
        if (username == "" || password == "" || email == "" || firstname == "" || lastname == "" || shopname == "" || shopaddress == "")
        {
            return
        }
        
        let dateFormatting = DateFormatter()
        dateFormatting.dateFormat = "yyyy-MM-dd"
        /* let chosenDate = dateFormatting.string(from: bdayAccCreationPicker.date)
        
        print(chosenDate); */
        
        DoRegister(username!, password!, email!, fullname, "", shopname!, shopaddress!, aboutUsTextView.text!);
        
    }
    
    
    func DoRegister(_ user: String, _ psw: String, _ email: String, _ fullname: String, _ birthdate: String, _ shopname: String, _ shopaddress: String, _ description: String) {
        
        let url = URL(string: "http://shop.thedmproject.info/register.php");
        let session = URLSession.shared;
        
        let request = NSMutableURLRequest(url: url!);
        
        request.httpMethod = "POST";
        
        // let paramToSend = "email=" + email + "&username=" + user + "&password=" + psw + "&birthdate=" + "0" + "&fullname=" + fullname + "&shopname=" + shopname + "&shopaddress=" + shopaddress + "&type=" + "3";
        
        let testURL = "https://maps.google.com/maps/api/geocode/json?address=" + shopaddress.replacingOccurrences(of: " ", with: "%20");
        
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
                
                let paramToSend = ["email" : email, "username" : user, "birthdate" : birthdate, "fullname" : fullname, "shopname" : shopname, "shopaddress" : shopaddress, "latitude" : latitude!, "longitude" : longitude!, "type" : 3, "rating" : 0.0, "ratingAmount" : 0, "phonenumber" : phoneNumberCreationTextField.text!, "aboutus" : description] as [String : Any];
                
                Auth.auth().createUser(withEmail: email, password: psw, completion: { (user, error) in
                    let ref = Database.database().reference();
                    
                    let defaults = UserDefaults.standard;
                    
                    mainUser = Shop();
                    
                    mainUser.key = user!.uid;
                    mainUser.email = email;
                    mainUser.username = self.usernameAccCreationTextField.text!;
                    mainUser.firstName = fullname;
                    mainUser.latitude = latitude;
                    mainUser.longitude = longitude;
                    mainUser.type = 3;
                    (mainUser as! Shop).rating = 0.0;
                    (mainUser as! Shop).phoneNumber = self.phoneNumberCreationTextField.text!;
                    (mainUser as! Shop).address = Address();
                    (mainUser as! Shop).address.fullAddress = shopaddress;
                    
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
                            
                            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
                            
                            self.present(viewController, animated: true, completion: nil);
                    })
                    
                });

            }
        }
        catch {
            self.view.makeToast("Invalid address! Please check your address and try again.", duration: 2.0, position: .center);
        }
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
            print(json!);
            
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
        })
        
        task.resume();
     
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
        
        self.present(viewController, animated: true, completion: nil);
        
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
        
        aboutUsTextView.text = "Placeholder"
        aboutUsTextView.textColor = UIColor.lightGray
        aboutUsTextView.delegate = self;
        
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latitude = manager.location?.coordinate.latitude;
        longitude = manager.location?.coordinate.longitude;
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if aboutUsTextView.textColor == UIColor.lightGray {
            aboutUsTextView.text = nil
            aboutUsTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if aboutUsTextView.text.isEmpty {
            aboutUsTextView.text = "Placeholder"
            aboutUsTextView.textColor = UIColor.lightGray
        }
    }
}

