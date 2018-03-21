//
//  MainMenu.swift
//  BarbershopsApp
//
//  Created by Alex Sadakhom on 2017-06-13.
//  Copyright © 2017 Codewater. All rights reserved.
//

import UIKit
import Toast_Swift
import CoreLocation
import Firebase
import ViewDeck
//code to force keyboard away when clicked away from a textfield in this view

class MainMenu: UIViewController, UITextFieldDelegate
{
    
    let locationManager = CLLocationManager()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        
        //calling function to hide keyboard when tapped away from textfields.
        self.hideKeyboardWhenTappedAround()
        self.toastStyling()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    
    @IBOutlet var usernameLogin : UITextField!
    @IBOutlet var passwordLogin :  UITextField!
    @IBOutlet var loginButton : UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func goBack()
    {
        let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController");
        
        self.present(viewController, animated: true, completion: nil);

    }
   
    @IBAction func login_Button (_ sender: Any){
        
        
        let username = usernameLogin.text
        let password = passwordLogin.text
        
        if (username == "" || password == "")
        {
            return
        }
        
        DoLogin(username!, password!);
        
    }
    
    
    func DoLogin(_ user: String, _ psw: String) {
        
        Auth.auth().signIn(withEmail: user, password: psw, completion: { (user, error) in
            
            if (user != nil)
            {
                let defaults = UserDefaults.standard;
                defaults.setValue( user!.uid , forKey: "user_id");
                
                let ref = Database.database().reference();
                
                ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    
                    if (value != nil)
                    {
                        let type = value!["type"] as! Int;
                        
                        if (type == 3)
                        {
                            mainUser = Shop();
                            
                            (mainUser as! Shop).firstName = value!["shopname"] as! String;
                            (mainUser as! Shop).username = value!["username"] as! String;
                            (mainUser as! Shop).rating = value!["rating"] as! Double;
                            (mainUser as! Shop).address = Address();
                            (mainUser as! Shop).address.fullAddress = value!["shopaddress"] as! String;
                            (mainUser as! Shop).key = snapshot.key;
                            
                            if (value!["aboutus"] != nil)
                            {
                                mainUser.bio = value!["aboutus"] as! String;
                            }
                            
                            if (value!["latitude"] != nil)
                            {
                                (mainUser as! Shop).latitude = value!["latitude"] as! Double;
                            }
                            
                            if (value!["longitude"] != nil)
                            {
                                (mainUser as! Shop).longitude = value!["longitude"] as! Double;
                            }
                            
                            mainUser.email = value!["email"] as! String;
                            mainUser.type = type;
                            
                            mainUser.key = snapshot.key;
                            
                            let appointmentShot = value!["appointments"] as? NSDictionary;
                            
                            if (appointmentShot != nil)
                            {
                                var appointment : Appointment;
                                
                                for appointmentDate in appointmentShot!
                                {
                                    var allAppointments = [Appointment]();
                                    
                                    for appointments in (appointmentDate.value as! NSDictionary)
                                    {
                                        appointment = Appointment();
                                        
                                        let currAppointment = appointments.value as! NSDictionary;
                                        
                                        appointment.date = shortDateFormatter.date(from: currAppointment["date"]! as! String)!;
                                        appointment.key = appointments.key as! String;
                                        appointment.time = TimeSlot();
                                        appointment.time.stringToSchedule(string: currAppointment["time"]! as! String);
                                        appointment.barber = Barber();
                                        appointment.barber.key = currAppointment["barberid"]! as! String;
                                        appointment.client = User();
                                        appointment.client.key = currAppointment["userid"]! as! String;
                                        
                                        allAppointments.append(appointment);
                                    }
                                    
                                    if ((mainUser as! Shop).appointments[appointmentDate.key as! String] == nil)
                                    {
                                        (mainUser as! Shop).appointments[appointmentDate.key as! String] = [Appointment]();
                                    }
                                    
                                    (mainUser as! Shop).appointments[appointmentDate.key as! String]! = allAppointments;
                                }
                            }
                            
                            let promotionShot = value!["promotions"] as? NSDictionary;
                            
                            if (promotionShot != nil)
                            {
                                var promotion : Promotion;
                                var i = 0;
                                
                                for currPromotion in promotionShot!
                                {
                                    promotion = Promotion();
                                    
                                    promotion.bio = currPromotion.value as! String;
                                    promotion.promoKey = currPromotion.key as! String;
                                    promotion.shopKey = mainUser.key;
                                    promotion.pk = i;
                                    
                                    i += 1;
                                    (mainUser as! Shop).promotions.append(promotion);
                                }
                            }

                            
                            let barberShot = value!["barbers"] as? NSDictionary;
                            
                            var barber : Barber;
                            
                            if (barberShot != nil)
                            {
                                for barbers in (barberShot!.allValues as! [String])
                                {
                                    barber = Barber();
                                    
                                    barber.key = barbers;
                                    
                                    (mainUser as! Shop).barbers.append(barber);
                                }
                            }
                            
                            let styleShot = value!["styles"] as? NSDictionary;
                            
                            var style : Style;
                            
                            if (styleShot != nil)
                            {
                                for styles in styleShot!
                                {
                                    style = Style();
                                    
                                    let currStyle = styles.value as! NSDictionary;
                                    
                                    var i = 0;
                                    
                                    style.key = styles.key as! String;
                                    style.name = styles.key as! String;
                                    style.price = currStyle["price"] as! Double;
                                    style.time = currStyle["duration"] as! Int;
                                    style.details = currStyle["details"] as! String;
                                    
                                    (mainUser as! Shop).styles.append(style);
                                }
                            }
                            
                        }
                        else if (type == 2)
                        {
                            mainUser = Barber();
                            
                            mainUser.username = value!["username"] as! String;
                            mainUser.email = value!["email"] as! String;
                            mainUser.key = snapshot.key;
                            mainUser.type = type;
                            
                            if (value!["latitude"] != nil)
                            {
                                mainUser.latitude = value!["latitude"] as! Double;
                            }
                            
                            if (value!["longitude"] != nil)
                            {
                                mainUser.longitude = value!["longitude"] as! Double;
                            }
                            
                            (mainUser as! Barber).schedule = TimeSlot();
                            (mainUser as! Barber).schedule.stringToSchedule(string: value!["schedule"] as! String);
                            
                            let appointmentShot = value?["appointments"] as? NSDictionary;
                            
                            if (appointmentShot != nil)
                            {
                                var appointment : Appointment;
                                
                                for appointmentDate in appointmentShot!
                                {
                                    appointment = Appointment();
                                    
                                    for appointments in (appointmentDate.value as! NSDictionary)
                                    {
                                        let currAppointment = appointments.value as! NSDictionary;
                                        
                                        appointment.date = shortDateFormatter.date(from: currAppointment["date"]! as! String)!;
                                        appointment.time = TimeSlot();
                                        appointment.time.stringToSchedule(string: currAppointment["time"]! as! String);
                                        appointment.barber = Barber();
                                        appointment.barber.key = currAppointment["barberid"]! as! String;
                                        appointment.client = User();
                                        appointment.client.key = currAppointment["userid"]! as! String;
                                        
                                        if ((mainUser as! Barber).appointments[appointmentDate.key as! String] == nil)
                                        {
                                            (mainUser as! Barber).appointments[appointmentDate.key as! String] = [Appointment]();
                                        }
                                        
                                        (mainUser as! Barber).appointments[appointmentDate.key as! String]!.append(appointment);
                                    }
                                }
                                
                            }
                        }
                        else
                        {
                            mainUser = User();
                            
                            mainUser.username = value!["username"] as! String;
                            mainUser.email = value!["email"] as! String;
                            mainUser.key = snapshot.key;
                            mainUser.type = type;
                            
                            if (value!["latitude"] != nil)
                            {
                                (mainUser as! Shop).latitude = value!["latitude"] as! Double;
                            }
                            
                            if (value!["longitude"] != nil)
                            {
                                (mainUser as! Shop).longitude = value!["longitude"] as! Double;
                            }
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
            else
            {
                self.view.makeToast("You have entered an incorrect email/password. Please sign in and try again.", duration: 2.0, position: .center, title: "Error!", image: nil, style: nil, completion: nil);

            }
        });
        
        /* let url = URL(string: "http://shop.thedmproject.info/login.php");
        let session = URLSession.shared;
        
        let request = NSMutableURLRequest(url: url!);
        
        request.httpMethod = "POST";
        
        let paramToSend = "login=" + user + "&password=" + psw;
        
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
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

            
            //dump (server_response);
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
                        
                defaults.setValue(self.usernameLogin.text!, forKey: "user_name");
                defaults.setValue(self.passwordLogin.text!, forKey: "user_pass");
                        
                if (defaults.synchronize() == false)
                {
                    print("Didnt save");
                };
                
                DispatchQueue.main.async {
                    self.view.makeToast("Successfully Logged in...", duration: 2.0, position: .center)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute:
                {
                                
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
                                
                    self.present(viewController, animated: true, completion: nil);
                })

            }
                
                
                //}
            
        
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
        
        task.resume(); */
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
