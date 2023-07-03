//
//  BaseViewController.swift
//  AppPit
//
//  Created by Nguyễn Hà on 01/08/2022.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        touchout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    func touchout() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func nextScreen(ctrl: UIViewController) {
        self.navigationController?.pushViewController(ctrl, animated: true)
    }

    func backScreen() {
        self.navigationController?.popViewController(animated: true)
    }

    func showScreen(ctrl: UIViewController, fullScreen: Bool? = false) {
        if fullScreen == true {
            ctrl.modalPresentationStyle = .overCurrentContext
            ctrl.modalTransitionStyle = .crossDissolve
        } else {
            ctrl.modalTransitionStyle = .coverVertical
        }
        if tabBarController != nil {
            self.tabBarController?.present(ctrl, animated: true)
        } else {
            self.present(ctrl, animated: true)
        }
    }

    func dismissScreen() {
        self.dismiss(animated: true)
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

}
