//
//  ChatCell.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 11.01.2024.
//

import UIKit

protocol ChatCellDelegate: AnyObject{
    func cell(wantsToPlayVideo cell: ChatCell, videoURL: URL?)
    func cell(wantsToShowImage cell: ChatCell, imageURL: URL?)
    func cell(wantsToPlayAudio cell: ChatCell, audioURL: URL?, isPlay: Bool)
    func cell(wantsToShowLocation cell: ChatCell, locationURL: URL?)
}

class ChatCell: UICollectionViewCell{
    
    //MARK: - Properties
    
    weak var delegate: ChatCellDelegate?
    
    var viewModel: MessageViewModel?{
        didSet{configure()}
    }
    
    private let profileImageView = CustomImageView(width: 30, height: 30, backgroundColor: .lightGray, cornerRadius: 15)
    private let dateLabel = CustomLabel(text: "10/10/2024", labelFont: .systemFont(ofSize: 12), labelColor: .lightGray)
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9245408177, green: 0.9278380275, blue: 0.9309870005, alpha: 1)
        return view
    }()

    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    
    var dateRightAnchor: NSLayoutConstraint!
    var dateLeftAnchor: NSLayoutConstraint!
    
    private let textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.font = .systemFont(ofSize: 16)
        tv.text = "Sample Text"
        return tv
    }()
    
    private lazy var postImage: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImage))
        let iv = CustomImageView()
        iv.isHidden = true
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var postVideo: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("Play Video", for: .normal)
        button.addTarget(self, action: #selector(handleVideoButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postAudio: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("Play Audio", for: .normal)
        button.addTarget(self, action: #selector(handleAudioButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var postLocation: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.setTitle("Google Map", for: .normal)
        button.addTarget(self, action: #selector(handleLocationButton), for: .touchUpInside)
        return button
    }()
    
    var isVoicePlaying: Bool = true
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 10)
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleLeftAnchor.isActive = false
        
        addSubview(dateLabel)
        
        dateLeftAnchor = dateLabel.leftAnchor.constraint(equalTo: bubbleContainer.rightAnchor, constant: 12)
        dateLeftAnchor.isActive = false
        
        dateRightAnchor = dateLabel.rightAnchor.constraint(equalTo: bubbleContainer.leftAnchor, constant: -12)
        dateRightAnchor.isActive = false
        
        dateLabel.anchor(bottom: bottomAnchor)
        
        addSubview(postImage)
        postImage.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postVideo)
        postVideo.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)

        addSubview(postAudio)
        postAudio.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        addSubview(postLocation)
        postLocation.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleLocationButton(){
        guard let viewModel = viewModel else{return}
        delegate?.cell(wantsToShowLocation: self, locationURL: viewModel.locationURL)
    }
    
    @objc func handleImage(){
        guard let viewModel = viewModel else{return}
        delegate?.cell(wantsToShowImage: self, imageURL: viewModel.imageURL)
    }
     
    @objc func handleVideoButton(){
        guard let viewModel = viewModel else{return}
        delegate?.cell(wantsToPlayVideo: self, videoURL: viewModel.videoURL)
    }
    
    @objc func handleAudioButton(){
        guard let viewModel = viewModel else{return}
        delegate?.cell(wantsToPlayAudio: self, audioURL: viewModel.audioURL, isPlay: isVoicePlaying)
        
        isVoicePlaying.toggle()
        let title = isVoicePlaying ? " Play Audio" : " Stop Audio"
        let imageName = isVoicePlaying ? "play.fill" : "stop.fill"
        postAudio.setTitle(title, for: .normal)
        postAudio.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    //MARK: - Helpers
    
    func resetAudioSettings(){
        postAudio.setTitle("Play Audio", for: .normal)
        postAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
        isVoicePlaying = true
    }
    
    func configure(){
        guard let viewModel = viewModel else{return}
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.text = viewModel.messageText
        textView.textColor = viewModel.messageColor
        
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        dateRightAnchor.isActive = viewModel.rightAnchorActive
        
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        dateLeftAnchor.isActive = viewModel.leftAnchorActive
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        
        guard let timestampString = viewModel.timestampString else{return}
        dateLabel.text = timestampString
        
        postImage.sd_setImage(with: viewModel.imageURL)
        textView.isHidden = viewModel.isTextHide
        postImage.isHidden = viewModel.isImageHide
        postVideo.isHidden = viewModel.isVideoHide
        postAudio.isHidden = viewModel.isAudioHide
        postLocation.isHidden = viewModel.isLocationHide

        
        if !viewModel.isImageHide{
            postImage.setHeight(200)
        }
    }
}

