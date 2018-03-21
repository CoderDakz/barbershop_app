//
//  User.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import IGListKit

class User : NSObject, ListDiffable
{
    
    var username: String;
    var email: String;
    var password : String;
    var firstName: String;
    var lastName: String;
    var bio: String;
    var profilePic: UIImage!;
    var latitude: Double?;
    var longitude: Double?;
    var key: String;
    var messages: [String:[Message]];
    var messageList: [String];
    var type: Int;
    var pk: Int;
    
    override init()
    {
        self.username = "";
        self.firstName = "";
        self.lastName = "";
        self.bio = "";
        self.profilePic = nil;
        self.pk = 0;
        self.email = "";
        self.password = "";
        self.key = "";
        self.messages = [String:[Message]]();
        self.messageList = [String]();
        self.type = 0;
        
    }
    
    convenience init(username: String, firstName: String, lastName: String, bio: String, primaryKey: Int) {
        
        self.init();
        
        self.username = username;
        self.firstName = firstName;
        self.lastName = lastName;
        self.bio = bio;
        self.profilePic = nil;
        self.pk = primaryKey;
        self.key = "";
        self.type = 0;
        self.messages = [String:[Message]]();
        self.messageList = [String]();

    }
    
    convenience init(primaryKey: Int)
    {
        self.init();
        
        self.username = "";
        self.firstName = "";
        self.lastName = "";
        self.bio = "";
        self.profilePic = nil;
        self.pk = primaryKey;
        self.key = "";
        self.type = 0;
        self.messages = [String:[Message]]();
        self.messageList = [String]();

    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? User else { return false }
        return username == object.username && firstName == object.firstName
            && lastName == object.lastName && bio == object.bio && pk == object.pk;

    }
    
    public func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }
}
