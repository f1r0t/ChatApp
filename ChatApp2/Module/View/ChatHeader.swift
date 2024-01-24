//
//  ChatHeader.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 15.01.2024.
//

import UIKit

class ChatHeader: UICollectionReusableView{
    
    var dateValue : String?{
        didSet{configure()}
    }
    private let dateLabel: CustomLabel = {
        let label = CustomLabel(text: "11/11/2023", labelFont: .systemFont(ofSize: 14), labelColor: .white)
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        label.setDimensions(height: 30, width: 100)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dateLabel)
        dateLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        guard let dateValue = dateValue else{return}
        dateLabel.text = dateValue
    }
}
