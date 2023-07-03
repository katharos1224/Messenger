//
//  AuthenticationLoginViewController.swift
//  Messenger
//
//  Created by Truong Nguyen Huu on 26/12/2022.
//

import UIKit
import LocalAuthentication
import JGProgressHUD
import FirebaseAuth

class AuthenticationLoginViewController: BaseViewController {

    @IBOutlet weak var passwordField: InputFieldView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var faceIdButton: UIButton!

    private let spinner = JGProgressHUD(style: .dark)
    var user: UserObject? = ServiceSettings.shared.userInfo
    var backAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        nameField.text = user?.name

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        passwordField.editingDidBegin = { [weak self] in
            guard let `self` = self else { return }
            if let email = self.user?.email, castToBool(self.user?.isSavedPass) {
                let password = KeyChain.load(key: email)
                if let password = password {
                    self.passwordField.value = String(decoding: password, as: UTF8.self)
                }
//                UIAlertController.showDefaultAlert(andMessage: "Use \"\(email)\"?)") { index in
//                    if index == 0 {
//                        self.passwordField.value = password?.to(type: String.self)
//                    }
//                }
            }
        }
    }

    func alertUserLoginError(message: String = "Incorrect account or password") {
        let alert = UIAlertController(title: "Woops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @IBAction private func loginButtonTaped() {
        
        passwordField.resignFirstResponder()
        
        guard let email = user?.email, let password = passwordField.value, !email.isEmpty, !password.isEmpty else {
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

                let safeEmail = DatabaseManager.safeEmai(emailAddress: email)
                DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                    switch result {
                    case .success(let data):
                        guard let userData = data as? [String: Any],
                              let firstName = userData["first_name"] as? String,
                              let lastName = userData["last_name"] as? String else {
                            return
                        }
                        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    case .failure(let error):
                        print("Failed to read data with error \(error)")
                    }
                }
                Constant.password = password
                UserDefaults.standard.set(email, forKey: "email")
//                PasswordManager.save(password, for: email, server: "https://www.google.com")
                let int: Int = 555
                let data = Data(from: int)
                let status: () = KeyChain.save(key: "MyNumber", data: data)
                print("status: ", status)
                    
                if let receivedData = KeyChain.load(key: "MyNumber") {
                    let result = receivedData.to(type: Int.self)
                    print("result: ", result)
                }
                print("Logged in user \(user)")
                strongSelf.navigationController?.popViewController(animated: true)
                if let backAction = strongSelf.backAction {
                    backAction()
                }
            })
        })
    }

    @IBAction private func onClickFaceAuthentication() {
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authorize with touch id"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                guard success, error == nil, let `self` = self else { return }
                if let backAction = self.backAction {
                    backAction()
                }

                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction private func onClickBack() {
//        self.navigationController?.popViewController(animated: true)
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
