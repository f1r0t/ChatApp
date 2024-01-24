//
//  ConversationViewController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 10.01.2024.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController{
    
    //MARK: - Properties
    
    private var user: User
    private let tableView = UITableView()
    private let reuseIdentifier = "ConversationCell"
    
    private let unReadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "8"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.setDimensions(height: 40, width: 40)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var unReadCount: Int = 0{
        didSet{
            DispatchQueue.main.async {
                self.unReadMsgLabel.isHidden = self.unReadCount == 0}
        }
    }
    
    private var conversations: [Message] = []{
        didSet{
            emptyView.isHidden = !conversations.isEmpty
            tableView.reloadData()
        }
    }
    
    private var filterConversation: [Message] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var conversationDictionary = [String: Message]()
    
    var inSearchMode: Bool{
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let emptyLabel = CustomLabel(text: "There are no conversation, click to start chatting now", labelColor: .yellow)
    
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 40, width: 40)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleProfileButton), for: .touchUpInside)
        return button
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
        configureUI()
        configureTableView()
        fetchConversations()
        configureSearchController()
    }
    
    //MARK: - Actions
    
    @objc func handleUpdateProfile(){
        UserService.fetchUser(uid: user.uid) { user in
            self.user = user
            self.title = user.fullname
        }
    }
    
    @objc func handleProfileButton(){
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch  {
            print("Error sign out")
        }
    }
    
    @objc func handleNewChat(){
        let controller = NewChatViewController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func fetchConversations(){
        
        MessageService.fetchRecentMessages {[self] conversations in
            conversations.forEach { conversation in
                self.conversationDictionary[conversation.chatPartnerID] = conversation
            }
            
            self.conversations = Array(self.conversationDictionary.values)
            
            unReadCount = 0
            
            self.conversations.forEach { message in
                unReadCount = unReadCount + message.newMessage
            }
            unReadMsgLabel.text = "\(unReadCount)"
            UIApplication.shared.applicationIconBadgeNumber = unReadCount
        }
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.backgroundColor = .white
        tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    private func configureUI(){
        title = user.fullname
        view.backgroundColor = .white
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let newConversationButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewChat))
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = newConversationButton
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
        
        view.addSubview(unReadMsgLabel)
        unReadMsgLabel.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 20, paddingBottom: 10)
        
        
        view.addSubview(profileButton)
        profileButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 10, paddingRight: 20)
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: profileButton.topAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 25, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateProfile), name: .userProfile, object: nil)
        
    }
    
    private func configureSearchController(){
        searchController.hidesNavigationBarDuringPresentation =  false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
    }
    
    private func openChat(currentUser: User, otherUser: User){
        let controller = ChatViewController(currentUser: currentUser, otherUser: otherUser)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - TableView

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterConversation.count : conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell
        
        let conversation = inSearchMode ? filterConversation[indexPath.row] : conversations[indexPath.row]
        cell.viewModel = MessageViewModel(message: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = inSearchMode ? filterConversation[indexPath.row] : conversations[indexPath.row]
        showLoader(true)
        UserService.fetchUser(uid: conversation.chatPartnerID) { [self] otherUser in
            showLoader(false)
            openChat(currentUser: user, otherUser: otherUser)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            showLoader(true)
            let conversation = inSearchMode ? filterConversation[indexPath.row] : conversations[indexPath.row]
            
            MessageService.deleteMessages(otherUser: conversation.toID) { [self] error in
                self.showLoader(false)
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                if inSearchMode{
                    filterConversation.remove(at: indexPath.row)
                }else{
                    conversations.remove(at: indexPath.row)
                }
                tableView.reloadData()
            }
        }
    }
}

//MARK: - NewChatViewControllerDelegate

extension ConversationViewController: NewChatViewControllerDelegate{
    
    func controller(_ vc: NewChatViewController, wantsToChatWithUser otherUser: User) {
        vc.dismiss(animated: true, completion: nil)
        openChat(currentUser: user, otherUser: otherUser)
    }
    
    
    
}

//MARK: - UISearchResultsUpdating

extension ConversationViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else{return}
        filterConversation = conversations.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        
        tableView.reloadData()
    }
}

//MARK: - UISearchResultsUpdating

extension ConversationViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}
