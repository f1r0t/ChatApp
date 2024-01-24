//
//  CustomInputView.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 11.01.2024.
//

import UIKit

protocol InputContainerViewDelegate: AnyObject{
    func inputView(_ view: InputContainerView, wantsToUpload message: String)
    func inputViewForAttach(_ view: InputContainerView)
    func inputViewForAudio(_ view: InputContainerView, audioURL: URL)
}

class InputContainerView: UIView{
    
    //MARK: - Properties
    
    weak var delegate: InputContainerViewDelegate?
    
    let customInputTextView = CustomInputTextView()
    
    let divider = UIView()
        
    private lazy var postBackgroundColor: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostButton))
        let iv = CustomImageView(width: 40, height: 40, backgroundColor: .systemBlue, cornerRadius: 20)
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        iv.isHidden = true 
        return iv
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .white
        button.setDimensions(height: 28, width: 28)
        button.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var attachButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "paperclip.circle"), for: .normal)
        button.tintColor = .red
        button.setDimensions(height: 40, width: 40)
        button.addTarget(self, action: #selector(handleAttachButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
        button.tintColor = .red
        button.setDimensions(height: 40, width: 40)
        button.addTarget(self, action: #selector(handleRecordButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackview: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [customInputTextView, postBackgroundColor, attachButton, recordButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()
    
    //MARK: - Record Voice
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setDimensions(height: 40, width: 100)
        button.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 40, width: 100)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSendRecordButton), for: .touchUpInside)
        return button
    }()
    
    private let timerLabel = CustomLabel(text: "00:00")
    
    private lazy var recordStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, timerLabel, sendRecordButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()
    
    var duration: CGFloat = 0.0
    var timer: Timer!
    var recorder = AKAudioRecorder.shared
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(stackview)
        stackview.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 5)
        
        addSubview(postButton)
        postButton.center(inView: postBackgroundColor)

        customInputTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: postBackgroundColor.leftAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 5, paddingRight: 8)
        
        addSubview(divider)
        divider.backgroundColor = .lightGray
        divider.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
        addSubview(recordStackView)
        recordStackView .anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 12, paddingRight: 12)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: CustomInputTextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    //MARK: - Actions
    
    
    @objc func handleCancelButton(){
        recordStackView.isHidden = true
        stackview.isHidden = false
    }
    
    @objc func handleSendRecordButton(){
        recorder.stopRecording()
        
        //TODO: - Take the record audio file to upload
        let name = recorder.getRecordings.last ?? ""
        guard let audioURL = recorder.getAudioURL(name: name) else {return}
        self.delegate?.inputViewForAudio(self, audioURL: audioURL)
        
        
        recordStackView.isHidden = true
        stackview.isHidden = false
    }
    
    @objc func handleTextDidChange(){
        let isTextEmpty = customInputTextView.text.isEmpty || customInputTextView.text == "" || customInputTextView.text == nil
        
        postButton.isHidden = isTextEmpty
        postBackgroundColor.isHidden = isTextEmpty
        
        attachButton.isHidden = !isTextEmpty
        recordButton.isHidden = !isTextEmpty
    }
    
    @objc func handleRecordButton(){
        stackview.isHidden = true
        recordStackView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.recorder.myRecordings.removeAll() /// delete all record before start
            self.recorder.record() /// we'll start record voice
            self.setTimer()
        })

    }
    
    @objc func handleAttachButton(){
        delegate?.inputViewForAttach(self)
    }
    
    @objc func handlePostButton(){
        delegate?.inputView(self, wantsToUpload: customInputTextView.text)
    }
    
    @objc func updateTimer(){
        if recorder.isRecording && !recorder.isPlaying{
            duration += 1
            self.timerLabel.text = duration.timeStringFormatter
        }else{
            timer.invalidate()
            duration = 0
            self.timerLabel.text = "00:00"
        }

    }
    
    //MARK: - Helpers
    
    func clearTextView(){
        customInputTextView.text = ""
        customInputTextView.placeholderLabel.isHidden = false
        
        postButton.isHidden = true
        postBackgroundColor.isHidden = true
        recordButton.isHidden = false
        attachButton.isHidden = false
    }
    
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
}
