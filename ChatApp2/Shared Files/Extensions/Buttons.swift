//
//  Buttons.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import UIKit

extension UIButton{
    
    func attributedText(firstString: String, secondString: String){
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 16)]
        let attributedTitle = NSMutableAttributedString(string: "\(firstString) ", attributes: atts)
        
        let secondAtts: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.88), .font: UIFont.boldSystemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: secondString, attributes: secondAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func blackButton(title: String){
        setTitle(title, for: .normal)
        tintColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        setHeight(50)
        layer.cornerRadius = 5
        titleLabel?.font = .boldSystemFont(ofSize: 19)
        isEnabled = false

    }
}
