//
//  RegisterViewController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import UIKit

protocol RegisterViewControllerDelegate: AnyObject{
    func didSuccessCreateAccount(_ registerVC: RegisterViewController)
}

class RegisterViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel = RegisterViewModel()
    
    weak var delegate: RegisterViewControllerDelegate?
    
    private var profileImage: UIImage?
    
    private let emailTextField = CustomTextField(placeholder: "Email", keyboardType: .emailAddress, isSecure: false)
    private let passwordTextField = CustomTextField(placeholder: "Password", isSecure: true)
    private let fullnameTextField = CustomTextField(placeholder: "Fullname")
    private let usernameTextField = CustomTextField(placeholder: "Username")

    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Already Have an account?", secondString: "Login Up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.setDimensions(height: 140, width: 140)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handlePhotoButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.blackButton(title: "Sign In")
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        return button
        
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTextField()
    }
    
    //MARK: - Actions
    
    @objc func handleAlreadyHaveAccountButton(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePhotoButton(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUpButton(){
        guard let email = emailTextField.text?.lowercased() else{return}
        guard let password = passwordTextField.text else{return}
        guard let username = usernameTextField.text?.lowercased() else{return}
        guard let fullname = fullnameTextField.text else{return}
        guard let profileImage = profileImage else{return}
        
        let credential = AuthCredential(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage)
        
        showLoader(true)
        AuthService.registerUser(credential: credential) { error in
            self.showLoader(false)
            if let error = error{
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.delegate?.didSuccessCreateAccount(self)
        }
    }
    
    @objc func handleTextChanged(sender: UITextField){
//        if sender == emailTextField {
//            viewModel.email = sender.text
//        }else if sender == passwordTextField{
//            viewModel.password = sender.text
//        }
        switch sender {
        case emailTextField:
            viewModel.email = sender.text
        case passwordTextField:
            viewModel.password = sender.text
        case fullnameTextField:
            viewModel.fullname = sender.text
        case usernameTextField:
            viewModel.username = sender.text
        default:
            break
        }
        updateForm()
    }
    
    
    //MARK: - Helpers
    
    private func configureTextField(){
        emailTextField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)

    }
    
    private func updateForm(){
        signUpButton.isEnabled = viewModel.formIsFailed
        signUpButton.backgroundColor = viewModel.backgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
    
    private func configureUI(){
        view.backgroundColor = .white
        
        view.addSubview(photoButton)
        photoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, fullnameTextField, usernameTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: photoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        

    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else{return}
        self.profileImage = selectedImage
        photoButton.layer.cornerRadius = photoButton.frame.width/2
        photoButton.layer.masksToBounds = true
        photoButton.layer.borderColor = UIColor.black.cgColor
        photoButton.layer.borderWidth = 2
        
        photoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }
}
