//
//  InitialViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-21.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ViewDeck

class InitialViewController : UIViewController
{
    var legacy = 0;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        let defaults = UserDefaults.standard;

        if let user_id = defaults.string(forKey: "user_id")
        {
            let user_name = defaults.string(forKey: "user_name");
            let user_pass = defaults.string(forKey: "user_pass");
            // accType = defaults.string(forKey: "acc_type")!
            
            // var firebase_user_id = defaults.string(forKey: "firebase_userid");
            
            let ref = Database.database().reference();
            
            // firebase_user_id = "testId";
            
            ref.child("users").child(user_id).observeSingleEvent(of: .value, with: { (snapshot) in
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
                        (mainUser as! Shop).latitude = value!["latitude"] as! Double;
                        (mainUser as! Shop).longitude = value!["longitude"] as! Double;
                        (mainUser as! Shop).phoneNumber = value!["phonenumber"] as! String;
                        (mainUser as! Shop).address = Address();
                        (mainUser as! Shop).address.fullAddress = value!["shopaddress"] as! String;
                        (mainUser as! Shop).key = snapshot.key;
                        mainUser.email = value!["email"] as! String;
                        mainUser.type = type;
                        
                        if (value!["aboutus"] != nil)
                        {
                            mainUser.bio = value!["aboutus"] as! String;
                        }
                        
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
                        
                        if (barberShot != nil)
                        {
                            var barber : Barber;
                            
                            
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
                        
                        let messagesShot = value!["messages"] as? NSDictionary;
                        
                        if (messagesShot != nil)
                        {
                            for messages in (messagesShot!.allValues as! [String])
                            {
                                (mainUser as! Shop).messages[messages] = [Message]();
                                (mainUser as! Shop).messageList.append(messages);
                            }
                        }
                    }
                    else if (type == 2)
                    {
                        mainUser = Barber();
                        
                        mainUser.username = value!["username"] as! String;
                        mainUser.latitude = value!["latitude"] as! Double;
                        mainUser.longitude = value!["longitude"] as! Double;
                        mainUser.email = value!["email"] as! String;
                        mainUser.key = snapshot.key;
                        mainUser.type = type;
                        
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
                                    appointment.client.pk = Int(currAppointment["userid"]! as! String)!;
                                    
                                    if ((mainUser as! Barber).appointments[appointmentDate.key as! String] == nil)
                                    {
                                        (mainUser as! Barber).appointments[appointmentDate.key as! String] = [Appointment]();
                                    }
                                    
                                    (mainUser as! Barber).appointments[appointmentDate.key as! String]!.append(appointment);
                                }
                            }
                        }
                        
                        let messagesShot = value!["messages"] as? NSDictionary;
                        
                        if (messagesShot != nil)
                        {
                            for messages in (messagesShot!.allValues as! [String])
                            {
                                (mainUser as! Barber).messages[messages] = [Message]();
                                (mainUser as! Barber).messageList.append(messages);
                            }
                        }
                    }
                    else
                    {
                        mainUser = User();
                        
                        mainUser.username = value!["username"] as! String;
                        mainUser.firstName = value!["fullname"] as! String;
                        mainUser.latitude = value!["latitude"] as! Double;
                        mainUser.longitude = value!["longitude"] as! Double;
                        mainUser.email = value!["email"] as! String;
                        mainUser.key = snapshot.key;
                        mainUser.type = type;
                        
                        let messagesShot = value!["messages"] as? NSDictionary;
                        
                        if (messagesShot != nil)
                        {
                            for messages in (messagesShot!.allValues as! [String])
                            {
                                mainUser.messages[messages] = [Message]();
                                mainUser.messageList.append(messages);
                            }
                        }
                    }
                    
                    let moreInfoViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "MyNewerProfileViewController");
                    
                    let nviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNewController");
                    
                    let sideController = IIViewDeckController(center: moreInfoViewController, leftViewController: nviewController);
                    
                    self.present(sideController, animated: false, completion: nil);

                }
            });

            /* let url = URL(string: "http://shop.thedmproject.info/login.php");
            let session = URLSession.shared;
            
            let request = NSMutableURLRequest(url: url!);
            
            request.httpMethod = "POST";
            
            let paramToSend = "login=" + user_name! + "&password=" + user_pass!;
            
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
                
                
                // dump (server_response);
                print(json!);
                
                let data_block = server_response["success"] as! NSString
                
                if (data_block as String == user_id)
                {
                    
                    let ref = Database.database().reference();
                    
                    // firebase_user_id = "testId";
                    
                    ref.child("users").child(user_id).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        
                        if (value != nil)
                        {
                            // let type = value!["type"] as! Int;
                            let type = 3;
                            
                            if (type == 3)
                            {
                                mainUser = Shop();

                                (mainUser as! Shop).firstName = value!["shopname"] as! String;
                                (mainUser as! Shop).username = value!["username"] as! String;
                                (mainUser as! Shop).rating = value!["rating"] as! Int;
                                (mainUser as! Shop).latitude = value!["latitude"] as! Double;
                                (mainUser as! Shop).longitude = value!["longitude"] as! Double;
                                (mainUser as! Shop).address = Address();
                                (mainUser as! Shop).address.fullAddress = value!["shopaddress"] as! String;
                                (mainUser as! Shop).key = snapshot.key;
                                mainUser.email = value!["email"] as! String;
                                mainUser.type = type;
                                
                                mainUser.key = snapshot.key;
                                
                                let appointmentShot = value!["appointments"] as! NSDictionary;
                                
                                var appointment : Appointment;
                                
                                for appointmentDate in appointmentShot
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
                                
                                let promotionShot = value!["promotions"] as! NSDictionary;
                                
                                var promotion : Promotion;
                                var i = 0;
                                
                                for promotions in promotionShot
                                {
                                    promotion = Promotion();
                                    
                                    let currPromotion = promotions.value as! NSDictionary;
                                    
                                    promotion.bio = currPromotion["description"] as! String;
                                    promotion.promoKey = promotions.key as! String;
                                    promotion.pk = i;
                                    
                                    i += 1;
                                    (mainUser as! Shop).promotions.append(promotion);
                                    
                                }
                                
                                let barberShot = value!["barbers"] as! NSDictionary;
                                
                                var barber : Barber;
                                
                                for barbers in (barberShot.allValues as! [String])
                                {
                                    barber = Barber();
                                    
                                    barber.key = barbers;
                                    
                                    (mainUser as! Shop).barbers.append(barber);
                                }

                            }
                            else if (type == 2)
                            {
                                mainUser = Barber();
                                
                                mainUser.username = value!["username"] as! String;
                                mainUser.latitude = value!["latitude"] as! Double;
                                mainUser.longitude = value!["longitude"] as! Double;
                                mainUser.email = value!["email"] as! String;
                                mainUser.key = snapshot.key;
                                mainUser.type = type;
                                
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
                                            appointment.barber.barberId = currAppointment["barberid"]! as! String;
                                            appointment.client = User();
                                            appointment.client.pk = Int(currAppointment["userid"]! as! String)!;
                                            
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
                                mainUser.latitude = value!["latitude"] as! Double;
                                mainUser.longitude = value!["longitude"] as! Double;
                                mainUser.email = value!["email"] as! String;
                                mainUser.key = snapshot.key;
                                mainUser.type = type;

                            }
                        }
                    });
                    
                    DispatchQueue.main.async (execute: self.LoginDone)
                }
            })
            
            task.resume(); */

        }
        else
        {
            let moreInfoViewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController");
            
            present(moreInfoViewController, animated: false, completion: nil);

        }
        
    }
    
    func test()
    {
        self.legacy += 1;
    }
    
    func LoginDone()
    {
        let moreInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
        
        present(moreInfoViewController, animated: false, completion: nil);

    }
}
