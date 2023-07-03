//
//  FriendViewController.swift
//  Messenger
//
//  Created by Katharos on 03/01/2023.
//

import UIKit
import FirebaseAuth

class FriendViewController: UIViewController {
    
    private var conversations = [Conversation]()
    private let user = ServiceSettings.shared.userInfo

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(FriendTableViewCell.self, forCellReuseIdentifier: FriendTableViewCell.identifier)
        return table
        
    }()
    
    private let noFriendLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Friend!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .secondarySystemBackground
        view.addSubview(tableView)
        view.addSubview(noFriendLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startListeningForConversations()

        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.startListeningForConversations()
        })
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("Starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmai(emailAddress: email)
        
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                print("Successfully got conversation models")
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noFriendLabel.isHidden = false
                    return
                }
                self?.noFriendLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noFriendLabel.isHidden = false
                print("Failed to get conversations: \(error)")
            }
        }
    }
    
//    @objc private func didTapComposeButton() {
//        let vc = NewConversationViewController()
//        vc.completion = { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//
//            let currentConversations = strongSelf.conversations
//
//            if let targetConversation = currentConversations.first(where: {
//                $0.otherUserEmail == DatabaseManager.safeEmai(emailAddress: result.email ?? "")
//            }) {
//                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
//                vc.isNewConversation = false
//                vc.title = targetConversation.name
//                vc.navigationItem.largeTitleDisplayMode = .never
//                strongSelf.navigationController?.pushViewController(vc, animated: true)
//            } else {
//                strongSelf.createNewConversation(result: result)
//            }
//        }
//        let navVC = UINavigationController(rootViewController: vc)
//        present(navVC, animated: true)
//    }
    
//    private func createNewConversation(result: UserObject) {
//        let name = result.name
//        let email = DatabaseManager.safeEmai(emailAddress: result.email ?? "")
//        
//        //check in database if conversation with these 2 users exists
//        //if it does, reuser conversation id
//        //otherwise, use existing code
//        
//        DatabaseManager.shared.conversationExists(with: email) { [weak self] result in
//            guard let strongSelf = self else {
//                return
//            }
//            switch result {
//            case .success(let conversationId):
//                let vc = ChatViewController(with: email, id: conversationId)
//                vc.isNewConversation = false
//                vc.title = name
//                vc.navigationItem.largeTitleDisplayMode = .never
//                strongSelf.navigationController?.pushViewController(vc, animated: true)
//            case .failure(_):
//                let vc = ChatViewController(with: email, id: nil)
//                vc.isNewConversation = true
//                vc.title = name
//                vc.navigationItem.largeTitleDisplayMode = .never
//                strongSelf.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noFriendLabel.frame = CGRect(x: 10, y: (view.height - 100) / 2, width: view.width - 20, height: 100)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
                
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

}

extension FriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < conversations.count else { return UITableViewCell() }
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.identifier, for: indexPath) as! FriendTableViewCell
        cell.configure(with: model)
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            //begin delete
//            let conversationId = conversations[indexPath.row].id
//            tableView.beginUpdates()
//            self.conversations.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .left)
//
//            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { success in
//                if !success {
//                    // Add model and row back and show error
//
//                    print("Failed to delete conversation!")
//                }
//            }
//
//            tableView.endUpdates()
//        }
//    }
}
