//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Katharos on 16/11/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import SDWebImage
import LocalAuthentication

final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    private var user = ServiceSettings.shared.userInfo

    override func viewWillAppear(_ animated: Bool) {
        user = ServiceSettings.shared.userInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        data.append(ProfileViewModel(viewModelType: .info, title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")", handler: nil))
        data.append(ProfileViewModel(viewModelType: .info, title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")", handler: nil))
        data.append(ProfileViewModel(viewModelType: .faceLogin, title: "Login By Face ID", handler: nil))
        data.append(ProfileViewModel(viewModelType: .fastLogin, title: "Fast Login (Auto-Fill Password)", handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "Log Out", message: "Do you want to log out?", preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                
                guard let strongSelf = self else {
                    return
                }
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
                // Log out Facebook
                FBSDKLoginKit.LoginManager().logOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                    
                } catch {
                    print("Failed to log out!")
                }
            }))
            
            strongSelf.present(actionSheet, animated: true)
        }))
        
        view.backgroundColor = .secondarySystemBackground
        tableView.backgroundColor = .secondarySystemBackground
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmai(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        headerView.backgroundColor = .secondarySystemBackground
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        return headerView
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        if cell.textLabel?.text != "Log Out" {
            cell.backgroundColor = .secondarySystemBackground
        }
        
        //switch
        if viewModel.viewModelType == .faceLogin {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(castToBool(user?.isUsingBiometricAuth), animated: true)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        }
        
        if viewModel.viewModelType == .fastLogin {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(castToBool(user?.isSavedPass), animated: true)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchFastLoginChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        print("Face login changed \(sender.tag)!")
        if sender.isOn {
            let context = LAContext()
            var error: NSError? = nil
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authorize with touch id"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                    guard success, error == nil, let `self` = self else { return }
                    let user = UserObject(email: self.user?.email,
                                          name: self.user?.name,
                                          isUsingBiometricAuth: true,
                                          isSavePass: castToBool(self.user?.isSavedPass),
                                          isLogout: castToBool(self.user?.isLogout))
                    ServiceSettings.shared.userInfo = user
                }
            }
        } else {
            let user = UserObject(email: user?.email,
                                  name: user?.name,
                                  isUsingBiometricAuth: false,
                                  isSavePass: castToBool(user?.isSavedPass),
                                  isLogout: castToBool(user?.isLogout))
            ServiceSettings.shared.userInfo = user
        }
    }
    
    @objc func switchFastLoginChanged(_ sender: UISwitch!) {
        if sender.isOn {
            if let user = user, let email = user.email {
                UIAlertController.showDefaultAlert(andMessage: "Save password for \(email)?") { index in
                    if index == 0 {
                        let data = Data((castToString(Constant.password)).utf8)
                        KeyChain.save(key: email, data: data)
                        let user = UserObject(email: email,
                                              name: user.name,
                                              isUsingBiometricAuth: castToBool(user.isUsingBiometricAuth),
                                              isSavePass: true,
                                              isLogout: castToBool(user.isUsingBiometricAuth))
                        ServiceSettings.shared.userInfo = user
    //                    let data = Data(from: Constant.password)
                    }
                }
            }
        } else {
            let user = UserObject(email: user?.email,
                                  name: user?.name,
                                  isUsingBiometricAuth: castToBool(user?.isUsingBiometricAuth),
                                  isSavePass: false,
                                  isLogout: castToBool(user?.isUsingBiometricAuth))
            ServiceSettings.shared.userInfo = user
        }
    }
}

class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        textLabel?.text = viewModel.title
        
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .faceLogin:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        case .fastLogin:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        }
    }
}
