//
//  Extensions.swift
//  Barbershop
//
//  Created by user on 2017-05-30.
//  Copyright © 2017 Codewater. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }

}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension UIView {
    func roundCorners(_ amount: CGFloat)
    {
        self.layer.cornerRadius = amount;
        self.layer.masksToBounds = true;
    }
}

extension UILabel {
    func underLine()
    {
        let textRange = NSMakeRange(0, self.text!.characters.count)
        let attributedText = NSMutableAttributedString(string: self.text!)
        attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText

    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func toastStyling()
    {
        var style = ToastStyle()
        // style.messageColor = UIColor(red: 146/255, green: 121/255, blue: 255/255, alpha: 1)
        style.backgroundColor = UIColor(red: 146/255, green: 121/255, blue: 255/255, alpha: 1)
        style.titleAlignment = .center
        ToastManager.shared.style = style
    }
}

extension UITextField
{
    func underline()
    {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func setCustomtextfieldUnderline(with leftimage: UIImage )
    {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = UIImageView(image: leftimage)
        self.leftView?.contentMode = .center
        self.leftView?.frame = CGRect(x: (self.leftView?.frame.origin.x)!, y: (self.leftView?.frame.origin.x)!, width: (self.leftView?.frame.size.width)! + 10, height: (self.leftView?.frame.size.height)!)
    }
    
    func setCustomtextfieldUnderlineImage(with rightimage: UIImage )
    {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        border.frame = CGRect(x: 0, y: (self.frame.size.height) - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = UIImageView(image: nil)
        self.leftView?.contentMode = .center
        self.leftView?.frame = CGRect(x: (self.leftView?.frame.origin.x)!, y: (self.leftView?.frame.origin.x)!, width: (self.leftView?.frame.size.width)! + 10, height: (self.leftView?.frame.size.height)!)
        
        self.rightViewMode = UITextFieldViewMode.always
        self.rightView = UIImageView(image: rightimage)
        self.rightView?.contentMode = .center
        self.rightView?.frame = CGRect(x: (self.rightView?.frame.origin.x)!, y: (self.rightView?.frame.origin.x)!, width: (self.rightView?.frame.size.width)! + 10, height: (self.rightView?.frame.size.height)!)
    }
    
    
}

