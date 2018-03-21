//
//  RatingsViewController.swift
//  Barbershop
//
//  Created by user on 2017-06-25.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Firebase

class RatingsViewController : UIViewController
{
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var review: UITextView!
    
    var shopKey : String?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        review.text = "";
    }
    
    @IBAction func submitReview()
    {
        let ref = Database.database().reference();
        
        let paramToSend = ["ratings" : ratings.rating, "review" : review.text, "user_name" : mainUser.username] as [String : Any];
        ref.child(shopKey!).child("reviews").childByAutoId().setValue(paramToSend);
        
        updateReview();
        
        self.view.makeToast("Review submitted successfully!.", duration: 3.0, position: .center, title: "Review", image: nil, style: nil, completion: nil);
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                self.dismiss(animated: true, completion: nil);
        })
        
        /* let url = URL(string: "http://shop.thedmproject.info/submitreview.php");
        let session = URLSession.shared;
        
        let request = NSMutableURLRequest(url: url!);
        
        request.httpMethod = "POST";
        
        let paramToSend = "?rating=" + String(ratings.rating) + "&review=" + review.text!;
        
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
                DispatchQueue.main.async (execute: self.dismissController);
                
            }
            else{
                // Did not submit
            }

        })
        
        task.resume(); */

    }
    
    @IBAction func dismissController()
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    func updateReview()
    {
        let ref = Database.database().reference();
        
        ref.child("users").child(shopKey!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            if (value != nil)
            {
                var rating = value!["rating"] as! Double;
                var amount = value!["ratingAmount"] as! Int;
                
                amount += 1;
                
                rating *= Double(amount);
                
                rating += self.ratings.rating;
                
                rating /= Double(amount);
                
                ref.child("users").child(self.shopKey!).child("rating").setValue(rating);
                ref.child("users").child(self.shopKey!).child("ratingAmount").setValue(amount);

            }
        });
    }
}
