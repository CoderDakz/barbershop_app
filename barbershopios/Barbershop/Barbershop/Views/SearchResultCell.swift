//
//  SearchResultCell.swift
//  Barbershop
//
//  Created by user on 2017-06-04.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class SearchResultCell : UICollectionViewCell
{
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    @IBOutlet weak var userDistance: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    
}
