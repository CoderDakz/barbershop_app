//
//  ContatInfoView.swift
//  Barbershop
//
//  Created by user on 2017-06-28.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class ContactInfoView : UIView
{
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailIcon: UILabel!
    
    var vc : UIViewController?;
    
    func initialize()
    {
        // Add touch gestures for the labels, and underline the texts for them
        phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneClick)));
        emailIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailClick)));
        
        phoneLabel.underLine();
        emailIcon.underLine();
    }
    
    // Launch any phone applications to call the barber
    func phoneClick()
    {
        if let url = URL(string: "tel://\(phoneLabel.text)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    // Launch any email applications to email the barber
    func emailClick()
    {
        if let url = URL(string: "mailto://\(emailIcon.text)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
     
    @IBAction func okayPressed(sender: UIButton)
    {
        vc?.dismiss(animated: true, completion: nil);
    }
}
