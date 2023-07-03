//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Katharos on 18/12/2022.
//

import Foundation

enum ProfileViewModelType {
    case info, logout, faceLogin, fastLogin
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
