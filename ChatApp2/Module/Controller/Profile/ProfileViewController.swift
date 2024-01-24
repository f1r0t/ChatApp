//
//  ProfileViewController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 16.01.2024.
//

import UIKit

class ProfileViewController: UIViewController{
    
    //MARK: - Properties
    
    private var user: User
    
    private let profileImageView = CustomImageView(backgroundColor: .lightGray, cornerRadius: 20)
    
    private let tableView = UITableView()
    private let reuseIdentifier = "ProfileCell"
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        return button
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        configureData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateProfile), name: .userProfile, object: nil)
    }
    
    //MARK: - Actions
    
    @objc func handleUpdateProfile(){
        navigationController?.popViewController(animated: true)
        UserService.fetchUser(uid: user.uid) { user in
            self.user = user
            self.configureData()
        }
    }
    
    @objc func handleEditProfile(){
        let controller = EditProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }

    //MARK: - Helpers
    
    private func configureUI(){
        title = "My Profile"
        view.backgroundColor = .white
        
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1).isActive = true
        
        view.addSubview(tableView)
        tableView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 25, paddingRight: 20)
        
        view.addSubview(editButton)
        editButton.centerX(inView: view)
        editButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 20)
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 70
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    private func configureData(){
        tableView.reloadData()
        guard let imageURL = URL(string: user.profileImageURL) else{return}
        profileImageView.sd_setImage(with: imageURL)
        profileImageView.contentMode = .scaleAspectFill
    }
}

//MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileField.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        guard let field = ProfileField(rawValue: indexPath.row) else{return cell}
        
        cell.viewModel = ProfileViewModel(user: user, field: field)
        return cell
    }
}

//MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate{
    
}


