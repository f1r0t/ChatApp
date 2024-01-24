//
//  ChatViewController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 11.01.2024.
//

import UIKit
import SDWebImage
import ImageSlideshow
import SwiftAudioPlayer

class ChatViewController: UICollectionViewController{
    
    //MARK: - Properties
    
    private let reuseIdentifier = "ChatCell"
    private let chatHeaderIdentifier = "ChatHeader"
    private var messages = [[Message]]() {
        didSet{
            self.emptyView.isHidden = !messages.isEmpty
        }
    }
 
    private lazy var inputContainerView: InputContainerView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let iv = InputContainerView(frame: frame)
        iv.delegate = self
        return iv
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let emptyLabel = CustomLabel(text: "The conversation is new and encrypted", labelColor: .yellow)

    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    private lazy var attachAlert: UIAlertController = {
        let alert = UIAlertController(title: "Attach File", message: "Select the button you want to attach from", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.handleCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.handleGallery()
        }))

        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            self.present(self.locationAlert, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        return alert
    }()
    
    var currentUser: User
    var otherUser: User
    
    private lazy var locationAlert: UIAlertController = {
        let alert = UIAlertController(title: "Share Location", message: "Select the button you want to share location from", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Current Location", style: .default, handler: { _ in
            self.handleCurrentLocation()
        }))
        
        alert.addAction(UIAlertAction(title: "Google Map", style: .default, handler: { _ in
            self.handleGoogleMap()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        return alert
    }()
    
    //MARK: - Lifecycle
  
    init(currentUser: User, otherUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: chatHeaderIdentifier)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.markReadAllMessage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markReadAllMessage()
    }
    
    override var inputAccessoryView: UIView?{
        get {return inputContainerView}
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    //MARK: - Actions
    
    @objc func handleCurrentLocation(){
        FLocationManager.shared.start { info in
            guard let lat = info.latitude else{return}
            guard let lon = info.longitude else{return}
            self.uploadLocation(lat: String(lat), lon: String(lon))
            FLocationManager.shared.stop()
        }
    }
    
    @objc func handleGoogleMap(){
        let controller = ChatMapVC()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func uploadLocation(lat: String, lon: String){
        let locationURL = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)"
        self.showLoader(true)
        MessageService.fetchSingleRecentMessage(otherUser: otherUser) { unReadCount in
            MessageService.uploadMessages(locationURL: locationURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadCount) { error in
                self.showLoader(false)
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    private func handleCamera(){
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
    
    private func handleGallery(){
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
    
    //MARK: - Helpers
    
    private func uploadVideo(withVideoURL url: URL){
        showLoader(true)
        FileUploader.uploadVideo(url: url) { videoURL in
            MessageService.fetchSingleRecentMessage(otherUser: self.otherUser) { unReadMessageCount in
                MessageService.uploadMessages(videoURL: videoURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadMessageCount + 1) { error in
                    self.showLoader(false)
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        } failure: { error in
            self.showLoader(false)
                print(error.localizedDescription)
        }
    }
    
    private func uploadImage(withImage image: UIImage){
        showLoader(true)
        FileUploader.uploadImage(image: image) { imageURL in
            MessageService.fetchSingleRecentMessage(otherUser: self.otherUser) { unReadMessageCount in
                MessageService.uploadMessages(imageURL: imageURL, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadMessageCount + 1) { error in
                    self.showLoader(false)
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    private func configureUI(){
        title = otherUser.fullname
        collectionView.backgroundColor = .white
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        //mesajları kaydırırken header görünür yapma
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 70, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
    }
    
    private func fetchMessages(){
        MessageService.fetchMessages(otherUser: otherUser) { messages in
            
            let groupMessages = Dictionary(grouping: messages) { element -> String in
                let dateValue = element.timestamp.dateValue()
                let stringDateValue = self.stringValue(forDate: dateValue)
                return stringDateValue ?? ""
            }
            
            self.messages.removeAll()
            let sortedKeys = groupMessages.keys.sorted(by: {$0 < $1})
            sortedKeys.forEach { key in
                let values = groupMessages[key]
                self.messages.append(values ?? [])
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToLastItem()
        }
    }
    
    private func markReadAllMessage(){
        MessageService.markReadAllMessage(otherUser: otherUser)
    }
}

//MARK: - UICollectionView

extension ChatViewController{
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            guard let firstMessage = messages[indexPath.section].first else{return UICollectionReusableView()}
            let dateValue = firstMessage.timestamp.dateValue()
            let stringValue = stringValue(forDate: dateValue)
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: chatHeaderIdentifier, for: indexPath) as! ChatHeader
            cell.dateValue = stringValue
            return cell
        }
        return UICollectionReusableView()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = ChatCell(frame: frame)
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimeSize = cell.systemLayoutSizeFitting(targetSize)
        return .init(width: view.frame.width, height: estimeSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

//MARK: - ChatMapVCDelegate

extension ChatViewController: ChatMapVCDelegate{
    func didTapLocation(lat: String, lon: String) {
        navigationController?.popViewController(animated: true)
        uploadLocation(lat: lat, lon: lon)
    }
}

//MARK: - InputContainerViewDelegate

extension ChatViewController: InputContainerViewDelegate{
    func inputViewForAttach(_ view: InputContainerView) {
        present(attachAlert, animated: true, completion: nil)
    }
    
    func inputView(_ view: InputContainerView, wantsToUpload message: String) {
        MessageService.fetchSingleRecentMessage(otherUser: otherUser) { [self] unReadCount in
            MessageService.uploadMessages(message: message, currentUser: currentUser, otherUser: otherUser, unReadCount: unReadCount + 1) { _ in
                
                self.collectionView.reloadData()
            }
        }
        view.clearTextView()
        
    }
    
    func inputViewForAudio(_ view: InputContainerView, audioURL: URL) {
        self.showLoader(true)
        FileUploader.uploadAudio(audioURL: audioURL) { audioString in
            MessageService.fetchSingleRecentMessage(otherUser: self.otherUser) { unReadCount in
                MessageService.uploadMessages(audioURL: audioString, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadCount + 1) { error in
                    self.showLoader(false)
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}

//MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            guard let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String else{return}
            
            if mediaType == "public.image"{
                guard let image = info[.editedImage] as? UIImage else{return}
                self.uploadImage(withImage: image)
            }else{
                guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else{return}
                
                self.uploadVideo(withVideoURL: videoURL)
            }
        }
    }
}

//MARK: - ChatCellDelegate

extension ChatViewController: ChatCellDelegate{
    func cell(wantsToPlayVideo cell: ChatCell, videoURL: URL?) {
        guard let videoURL = videoURL else{return}
        let controller = VideoPlayerController(videoURL: videoURL)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(wantsToShowImage cell: ChatCell, imageURL: URL?) {
        let slideShow = ImageSlideshow()
        guard let imageURL = imageURL else{return}
        
        SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) { image, _, _, _, _, _ in
            guard let image = image else{return}
            
            slideShow.setImageInputs([
            ImageSource(image: image)
            ])
            
            slideShow.delegate = self as? ImageSlideshowDelegate
            
            let controller = slideShow.presentFullScreenController(from: self)
            controller.slideshow.activityIndicator = DefaultActivityIndicator()
        }
    }
    
    func cell(wantsToPlayAudio cell: ChatCell, audioURL: URL?, isPlay: Bool) {
        if isPlay{
            guard let audioURL = audioURL else{return}
            
            SAPlayer.shared.startRemoteAudio(withRemoteUrl: audioURL)
            SAPlayer.shared.play()
            
            let _ = SAPlayer.Updates.PlayingStatus.subscribe { playingStatus in
                if playingStatus == .ended{
                    cell.resetAudioSettings()
                }
            }
        }else{
            SAPlayer.shared.stopStreamingRemoteAudio()
        }
    }
    
    func cell(wantsToShowLocation cell: ChatCell, locationURL: URL?) {
        guard let googleURLApp = URL(string: "comgooglemaps://") else {return}
        guard let locationURL = locationURL else{return}
        
        if UIApplication.shared.canOpenURL(googleURLApp){
            ///here we have the app
        UIApplication.shared.open(locationURL)
        }else{
            ///we dont have the app
            UIApplication.shared.open(locationURL, options: [:])

        }

    }
}
