//
//  TestCell.swift
//  Barbershop
//
//  Created by user on 2017-06-06.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit

class TestCell: UICollectionViewCell {
    
    static let titleHeight: CGFloat = 30
    
    static func cellSize(width: CGFloat, text: String) -> CGSize {
        return CGSize(width: width, height: 55 + TestCell.titleHeight)
    }
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 1
        label.textColor = UIColor.white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        contentView.addSubview(messageLabel);
        contentView.backgroundColor = .blue;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        messageLabel.frame = CGRect(x: 0, y: 25, width: bounds.width, height: bounds.height - TestCell.titleHeight);

    }
}
