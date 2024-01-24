//
//  ProfileCell.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 17.01.2024.
//

import UIKit

class ProfileCell: UITableViewCell{
    
    //MARK: - Properties
    
    var viewModel: ProfileViewModel?{
        didSet{
            return configure()
        }
    }
    
    private let titleLabel = CustomLabel(text: "Name", labelColor: .red)
    private let userLabel = CustomLabel(text: "Fırat")
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, userLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configure(){
        guard let viewModel = viewModel else {return}
        
        titleLabel.text = viewModel.fieldTitle
        userLabel.text = viewModel.optionType
    }

}
