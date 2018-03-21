//
//  ReviewCell.swift
//  Barbershop
//
//  Created by user on 2017-06-29.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class ReviewCell : UICollectionViewCell
{
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var review: UITextView!
    
}
