//
//  GlobalFunctions.swift
//  Barbershop
//
//  Created by user on 2017-06-17.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

func showDialog(_ title: String, message: String, viewController: UIViewController)
{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
    }
    
    alertController.addAction(cancelAction)
    
    viewController.present(alertController, animated: true, completion: nil);
}

func coordinatesToKilometres(_ latitude1: Double, _ longitude1: Double, _ latitude2: Double, _ longitude2: Double) -> Double
{
    let R = 6371e3;
    let l1 = latitude1.degreesToRadians;
    let l2 = latitude2.degreesToRadians;
    
    let v1 = (latitude2 - latitude1).degreesToRadians;
    let v2 = (longitude2 - longitude1).degreesToRadians;
    
    let a = sin(v1/2) * sin(v1/2) + cos(l1) * cos(l2) * sin(v2/2) * sin(v2/2);
    let c = 2 * atan2(sqrt(a), sqrt(1-a));
    
    let d = R * c;
    
    return d;
}

func getCoordinateFromJSON(_ jsonString: String) -> Position?
{
    do
    {
        let json = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions()) as! [String : Any];
        
        let json1 = json["results"]! as! [Any];
        
        let json3 = json1[0] as! [String : Any];
        
        let json2 = json3["geometry"] as! [String : Any];
        
        let json4 = json2["location"]! as! [String : Any];
        
        let latitude = json4["lat"] as! Double;
        let longitude = json4["lng"] as! Double;
        
        return Position(latitude: latitude, longitude: longitude);
    }
    catch
    {
        return nil;
    }
}
