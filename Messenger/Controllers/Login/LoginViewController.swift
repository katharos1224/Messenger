//
//  LoginViewController.swift
//  Messenger
//
//  Created by Katharos on 16/11/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import JGProgressHUD

final class LoginViewController: BaseViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    //    private let forgotPasswordLabel: UILabel = {
    //        let label = UILabel()
    //        label.text = "Forgot Password?"
    //        label.textColor = .systemBlue
    //        label.font = .systemFont(ofSize: 13, weight: .regular)
    //        return label
    //    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        title = "Log In"
        view.backgroundColor = .secondarySystemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        navigationItem.rightBarButtonItem?.tintColor = .primaryColor
        
        loginButton.addTarget(self, action: #selector(loginButtonTaped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        // Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
//        scrollView.addSubview(forgotPasswordLabel)
        scrollView.addSubview(facebookLoginButton)
        checkExistUser()
    }
    
    func checkExistUser() {
        if let user = ServiceSettings.shared.userInfo {
            let vc = AuthenticationLoginViewController()
            vc.user = user
            vc.backAction = {
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 2
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: (scrollView.height - size) / 5, width: size, height: size)
        emailField.frame = CGRect(x: 50, y: imageView.bottom + 50, width: scrollView.width - 100, height: 50)
        passwordField.frame = CGRect(x: 50, y: emailField.bottom + 10, width: scrollView.width - 100, height: 50)
        loginButton.frame = CGRect(x: 50, y: passwordField.bottom + 30, width: scrollView.width - 100, height: 50)
//        forgotPasswordLabel.frame = CGRect(x: (scrollView.width - size) / 2 + 45, y: loginButton.bottom + 15, width: size - 60, height: 20)
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame.origin.y = loginButton.bottom + 20
    }
    
    @objc private func loginButtonTaped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
            alertUserLoginError(message: "Email or password cannot be blank!")
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In Methods
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
                
                guard let result = authResult, error == nil else {
                    self?.alertUserLoginError(message: "Incorrect account or password!")
                    print("Failed to log in user with email: \(email)" )
                    return
                }
                
                let user = result.user
                let userObject: UserObject = UserObject()
                
                let safeEmail = DatabaseManager.safeEmai(emailAddress: email)
                DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                    switch result {
                    case .success(let data):
                        guard let userData = data as? [String: Any],
                              let firstName = userData["first_name"] as? String,
                              let lastName = userData["last_name"] as? String else {
                            return
                        }
                        userObject.name = "\(firstName) \(lastName)"
                        if let emailInfo = ServiceSettings.shared.userInfo?.email, email == emailInfo {
                        } else {
                            ServiceSettings.shared.userInfo = userObject
                        }
                        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    case .failure(let error):
                        print("Failed to read data with error \(error)")
                    }
                }
                userObject.email = email
                Constant.password = password

                UserDefaults.standard.set(email, forKey: "email")
                
                print("Logged in user \(user)")
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func alertUserLoginError(message: String = "Incorrect account or password") {
        let alert = UIAlertController(title: "Woops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: UITextField Delegate Methods

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            loginButtonTaped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Failed to log in with Facebook.")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make Facebook graph request")
                return
            }
            
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureURL = data["url"] as? String else {
                      print("Failed to get email and name frome Facebook result")
                      return
                  }
            let userObject: UserObject = UserObject()
            userObject.email = email
            userObject.name = "\(firstName) \(lastName)"
            if let emailInfo = ServiceSettings.shared.userInfo?.email, email == emailInfo {
            } else {
                ServiceSettings.shared.userInfo = userObject
            }

            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completetion: { success in
                        if success {
                            
                            guard let url = URL(string: pictureURL) else {
                                return
                            }
                            
                            print("Downloading data from Facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from Facebook")
                                    return
                                }
                                
                                print("Got data from Facebook, uploading...")
                                
                                //Upload image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed - \(error)")
                    }
                    
                    return
                }
                
                print("Successfully logged user in.")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
}

//extension LoginViewController: UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if let email = self.emailField.text {
//            let password = PasswordManager.get(for: email, server: "firebase")
//            UIAlertController.showDefaultAlert(andMessage: "Use \"\(email)\"?)") { index in
//                if index == 0 {
//                    self.passwordField.text = password
//                }
//            }
//        }
//        return true
//    }
//}
