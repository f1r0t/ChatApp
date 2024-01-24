//
//  LoginViewController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel = LoginViewModel()
    
    private let welcomeLabel = CustomLabel(text: "HEY, WELCOME", labelFont: .boldSystemFont(ofSize: 20))
    
    private let profileImageView = CustomImageView(image: #imageLiteral(resourceName: "profile"), width: 50, height: 50)
    
    private let emailTextField = CustomTextField(placeholder: "Email", keyboardType: .emailAddress)
    
    private let passwordTextField = CustomTextField(placeholder: "Password", isSecure: true)
    
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.blackButton(title: "Login")
        button.addTarget(self, action: #selector(handleLoginVC), for: .touchUpInside)
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Forgot your password?", secondString: "Get Help Signing in")
        button.tintColor = .black
        button.backgroundColor = .white
        button.setHeight(50)
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Don't Have an account?", secondString: "Sign Up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignupButton), for: .touchUpInside)
        return button
    }()
    
    private let googleLabel = CustomLabel(text: "or continue with Google", labelColor: .lightGray)
    
    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleGoogleSignInVC), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForTextField()
    }
    
    //MARK: - Actions
    
    @objc func handleLoginVC(){
        guard let email = emailTextField.text?.lowercased() else {return}
        guard let password = passwordTextField.text?.lowercased() else {return}
        showLoader(true)
        AuthService.loginUser(email: email, password: password) { result, error in
            self.showLoader(false)
            if let error = error{
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.showLoader(false)
            print("başarılı")
            self.toConversationVC()
        }
        
    }
    
    @objc func handleForgotPassword(){
        
    }
    
    @objc func handleSignupButton(){
        let controller = RegisterViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGoogleSignInVC(){
        setupGoogle()
    }
    
    @objc func handleTextChanged(sender: UITextField){
        sender == emailTextField ? (viewModel.email = sender.text) : (viewModel.password = sender.text)
        updateForm()
    }
    
    //MARK: - Helpers
    
    private func configureUI(){
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        welcomeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        welcomeLabel.centerX(inView: view)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: welcomeLabel.bottomAnchor, paddingTop: 20)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        signUpButton.centerX(inView: view)
        
        view.addSubview(googleLabel)
        googleLabel.centerX(inView: view, topAnchor: forgotPasswordButton.bottomAnchor, paddingTop: 30)
        
        view.addSubview(googleButton)
        googleButton.centerX(inView: view, topAnchor: googleLabel.bottomAnchor, paddingTop: 12)
    }
    
    private func configureForTextField(){
        emailTextField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
    }
    
    private func updateForm(){
        loginButton.isEnabled = viewModel.formIsFailed
        loginButton.backgroundColor = viewModel.backgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        
    }
    
    func toConversationVC(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        showLoader(true)
        UserService.fetchUser(uid: uid) { user in
            self.showLoader(false)
            print(user)
            let controller = ConversationViewController(user: user)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}

//MARK: - RegisterViewControllerDelegate

extension LoginViewController: RegisterViewControllerDelegate{
    func didSuccessCreateAccount(_ registerVC: RegisterViewController) {
        registerVC.navigationController?.popViewController(animated: true)
        showLoader(false)
        toConversationVC()
    }
}
