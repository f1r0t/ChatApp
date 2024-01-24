//
//  CustomImageView.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import UIKit

class CustomImageView: UIImageView{
    
    init(image: UIImage? = nil, width: CGFloat? = nil, height: CGFloat? = nil,backgroundColor: UIColor? = nil, cornerRadius: CGFloat = 0) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
        if let image = image{
            self.image = image
        }
        
        if let width = width{
            setWidth(width)
        }
        
        
        if let height = height{
            setHeight(height)
        }
        
        if let backgroundColor = backgroundColor{
            self.backgroundColor = backgroundColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
