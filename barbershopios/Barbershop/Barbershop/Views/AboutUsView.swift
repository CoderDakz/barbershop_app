//
//  AboutUsView.swift
//  Barbershop
//
//  Created by user on 2017-07-08.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class AboutUsView : UIView
{
    @IBOutlet weak var aboutUs: UITextView!
    
    var vc : UIViewController?;

    @IBAction func okayPressed(sender: UIButton)
    {
        vc?.dismiss(animated: true, completion: nil);
    }
}
