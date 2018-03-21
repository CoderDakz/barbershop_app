//
//  BookAppointmentViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-06.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import Toast_Swift
import Firebase

class BookAppointmentViewController : UIViewController, FSCalendarDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var barberName: UILabel!
    @IBOutlet weak var appointmentDescription: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var dateDay: UILabel!
    @IBOutlet weak var dateDate: UILabel!
    @IBOutlet weak var dateMonthYear: UILabel!
    @IBOutlet weak var appointmentTime: UILabel!
    
    let formatter : DateFormatter = {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy";
        return dateFormatter;
    }();

    var appointment : Appointment?;
    var user : User?;
    var timeSelectedIndex = 32;
    
    var styleString = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        currentDate.text = "Select Date";
        appointmentTime.text = appointment!.time.getFirstReadableTime();
        
        let dateString = formatter.string(from: appointment!.date);
        let tokenizedString = dateString.components(separatedBy: ",");
        let monthDate = tokenizedString[1].components(separatedBy: " ");
        
        var totalPrice = 0.00
        
        self.dateDay.text = tokenizedString[0].uppercased();
        self.dateDate.text = monthDate[2];
        self.dateMonthYear.text = "\(monthDate[1].uppercased()) \(tokenizedString[2])";
        
        appointmentDescription.text!.removeAll();
        barberName.text = appointment?.barber.firstName;
        shopName.text = mainShop.firstName;
        
        if (styleCart != nil)
        {
            for style in styleCart
            {
                appointmentDescription.text! += "\(style.name) $\(String(format: "%.02f", style.price))\n";
                
                totalPrice = totalPrice + style.price
                
                styleString += style.key + ",";
                
                /* if(style.name == "Line up")
                {
                    styleString += "Line%20up"
                }
                else{
                    styleString += (style.name + ",")
                } */  
            }
            
            appointmentDescription.text! += "--------------------------------\n"
            appointmentDescription.text! += "Subtotal: $\(String(format: "%.02f", totalPrice))\n";
            
        }
        
    }
    
    @IBAction func bookAppointment(_ sender: UIButton) {
        
        self.appointment!.bio = appointmentDescription.text!;
        self.appointment!.style = styleCart;
        
        styleCart.removeAll();
        
        let currentDate = shortDateFormatter.string(from: appointment!.date);
        
        if (mainShop.appointments[currentDate] == nil)
        {
            mainShop.appointments[currentDate] = [Appointment]();
        }
        mainShop.appointments[currentDate]!.append(appointment!);
        
        self.view.makeToast("Check your bookings page to review or edit your appointment.", duration: 3.0, position: .center, title: "Appointment Booked!", image: nil, style: nil, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute:
        {
            self.dismiss(animated: true, completion: nil);
        })
        
        
        
        submitToServer();
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scheduleReadableTimes.count;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        appointmentTime.text = scheduleReadableTimes[row];
        timeSelectedIndex = row;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scheduleReadableTimes[row];
    }
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func segue()
    {
        
        /* let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController");
        
        self.present(vc, animated: true, completion: nil); */
        
        print("Hey");
        
    }
    
    func submitToServer()
    {
        let ref = Database.database().reference();
        
        let defaults = UserDefaults.standard
        let current_userid = defaults.string(forKey: "user_id")
        
        for style in appointment!.style
        {
            styleString += style.key + ",";
        }
        
        let paramToSend = ["time" : appointment!.time.scheduleToString(), "date" : shortDateFormatter.string(from: appointment!.date), "styles" : styleString, "userid" : mainUser.key, "barberid" : appointment!.barber.key];
        
        let reference = ref.child("users").child(mainShop.key).child("appointments").child(paramToSend["date"]!).childByAutoId();
        reference.setValue(paramToSend);
        
        ref.child("users").child(mainUser.key).child("appointments").child(paramToSend["date"]!).child(reference.key).setValue(paramToSend);
        ref.child("users").child(appointment!.barber.key).child("appointments").child(paramToSend["date"]!).child(reference.key).setValue(paramToSend);
        
        /* if ((mainUser as! Shop).appointments[shortDateFormatter.string(from: appointment!.date)] == nil)
        {
            (mainUser as! Shop).appointments[shortDateFormatter.string(from: appointment!.date)] = [Appointment]();
        }
        
        (mainUser as! Shop).appointments[shortDateFormatter.string(from: appointment!.date)]!.append(appointment!); */
        /* let defaults = UserDefaults.standard
        let current_userid = defaults.string(forKey: "user_id")
        
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        //HAD TO BREAK UP THESE because i was getting this error "expression-too-complex"
        let param1 = "time=" + appointment!.time.scheduleToString()
        let param2 = "&date=" + shortDateFormatter.string(from: appointment!.date)
        let param3 = "&styles=" + styleString
        let param4 = "&userid=" + current_userid!
        let param5 = "&barberid=" + "1" + "&shopid=" + "1"
        let paramToSend = param1 + param2 + param3 + param4 + param5
        
        paramToSend.addingPercentEncoding(withAllowedCharacters: allowedCharacters);
        
        let url_string = "http://shop.thedmproject.info/submitbooking.php?" + paramToSend
        
        let url = URL(string: url_string);
        let session = URLSession.shared;
        
        print(url_string)
        //print(paramToSend)
        
        //FATAL ERROR HERE......
        
        let request = NSMutableURLRequest(url: (url)!);
        
        
        
        request.httpMethod = "GET";
        
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
            print(json);
            
            if let data_block = server_response["success"] as? Int
            {
                
                
                // if let session_data = data_block["session"] as? String
                //{
                //print("\nSecond if statement\n")
                
                //let preferences = UserDefaults.standard
                //preferences.set(session_data, forKey: "session")
                
                
                
                DispatchQueue.main.async (
                    execute:self.segue
                )
                //}
            }
        })
        
        task.resume(); */
    }
}
