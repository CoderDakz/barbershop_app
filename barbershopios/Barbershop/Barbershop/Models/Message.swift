//
//  Message.swift
//  Barbershop
//
//  Created by user on 2017-07-01.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class Message : NSObject
{
    var message : String;
    var sender: String;
    var senderId: String;
    var key: String;
    
    override init()
    {
        self.message = "";
        self.sender = "";
        self.senderId = "";
        self.key = "";
    }
}
