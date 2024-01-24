//
//  EditProfileController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 17.01.2024.
//

import UIKit

class EditProfileController: UIViewController{
    
    //MARK: - Properties
    
    private let user: User
    
    var selectedImage: UIImage?
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSubmitProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileImageView: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        let iv = CustomImageView(width: 125, height: 125, backgroundColor: .lightGray, cornerRadius: 125 / 2)
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let fullnameLabel = CustomLabel(text: "Fullname", labelColor: .red)
    private let fullnameTextField = CustomTextField(placeholder: "fullname")
    
    private let usernameLabel = CustomLabel(text: "Username", labelColor: .red)
    private let usernameTextField = CustomTextField(placeholder: "username")
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureProfileData()
    }
    
    //MARK: - Actions
    
    @objc func handleImageTap(){
        present(imagePicker, animated: true)
    }
    
    @objc func handleSubmitProfile(){
        guard let fullname = fullnameTextField.text else{return}
        guard let username = usernameTextField.text else{return}
        showLoader(true)
        if selectedImage == nil{
            let params = [
                "fullname": fullname,
                "username": username
            ]
            updateUser(params: params)
        }else{
            guard let selectedImage = selectedImage else{return}
            FileUploader.uploadImage(image: selectedImage) { imageUrl in
                let params = [
                    "fullname": fullname,
                    "username": username,
                    "profileImageURL": imageUrl
                ]
                self.updateUser(params: params)
            }
        }
    }
    
    //MARK: - Helpers
    
    private func updateUser(params: [String:Any]){
        UserService.setNewUserData(data: params) { _ in
            self.showLoader(false)
            NotificationCenter.default.post(name: .userProfile, object: nil)
        }
    }
    
    private func configureProfileData(){
        fullnameTextField.text = user.fullname
        usernameTextField.text = user.username
        profileImageView.sd_setImage(with: URL(string: user.profileImageURL))
    }
    
    private func configure(){
        view.backgroundColor = .white
        title = "Edit Profile"
        
        view.addSubview(editButton)
        editButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingRight: 12)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: editButton.bottomAnchor, paddingTop: 10)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, fullnameTextField, usernameLabel, usernameTextField])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        fullnameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        self.selectedImage = image
        self.profileImageView.image = image
        dismiss(animated: true)
    }
}
